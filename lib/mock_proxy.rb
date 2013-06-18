# coding: utf-8

require 'net/http'
require 'sinatra/base'
require 'active_support/cache'

module MockProxy

  class App < Sinatra::Base

    set :opt, {
      :cache_path => './.cache',
      :mem_cache_size => 32.megabytes,
      :destination_host => 'localhost',
      :destination_port => 80
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
      path = "#{request.path}?#{request.query_string}"
      res = settings.mem_cache.fetch path do
        settings.file_cache.fetch path do
          Net::HTTP.get_response(settings.opt[:destination_host], path, settings.opt[:destination_port])
        end
      end
      if res.code != "200"
        settings.file_cache.delete path
        settings.mem_cache.delete path
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
