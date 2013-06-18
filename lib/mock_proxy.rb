# coding: utf-8

require 'net/http'
require 'digest/sha1'
require 'sinatra/base'
require 'active_support/cache'

module MockProxy

  class App < Sinatra::Base

    set :opt, {
      :cache_path => './.cache',
      :mem_cache_size => 32.megabytes,
      :destination_host => 'localhost',
      :destination_port => 80,
      :disable_proxy => false,
      :normalize_query => nil,
    }

    def App.[]=(key, value)
      opt[key] = value
    end

    file_cache = nil
    set :file_cache do
      file_cache ||= ActiveSupport::Cache::FileStore.new(opt[:cache_path])
    end

    mem_cache = nil
    set :mem_cache do
      mem_cache ||= ActiveSupport::Cache::MemoryStore.new(:size => opt[:mem_cache_size])
    end
    
    get /.*/ do
      mem_cache = settings.mem_cache
      file_cache = settings.file_cache
      path = "#{request.path}?#{request.query_string}"
      unless settings.opt[:normalize_query].nil?
        path = settings.opt[:normalize_query].call(path)
      end
      key = Digest::SHA1.digest(path).each_byte.map{|b| format('%x', b)}.to_a.join('')
      res = mem_cache.read(key)
      if res.nil?
        res = file_cache.read(key)
        mem_cache.write(key, res) unless res.nil?
      end
      if res.nil?
        return [503, {}, nil] if settings.opt[:disable_proxy]
        res = Net::HTTP.get_response(settings.opt[:destination_host], path, settings.opt[:destination_port])
        return [503, {}, nil] unless res.code == '200'
        mem_cache.write(key, res)
        file_cache.write(key, res)
      end
      headers = res.to_hash.inject({}){|hash, kv|
        key, val = kv
        hash[key] = val[0]
        hash
      }
      headers.delete("transfer-encoding")
      [res.code.to_i, headers, res.body]
    end

  end

end
