# coding: utf-8

require 'net/http'
require 'digest/sha1'
require 'sinatra/base'
require 'active_support/cache'

module MockProxy

  class App < Sinatra::Base

    use Rack::Logger

    set :opt, {
      :cache_path => './.cache',
      :mem_cache_size => 32.megabytes,
      :destination_host => 'localhost',
      :destination_port => 80,
      :disable_proxy => false,
      :normalize_query => nil,
      :wait_sec => nil,
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
      url = "http://#{settings.opt[:destination_host]}:#{settings.opt[:destination_port]}#{path}"
      if res.nil?
        if settings.opt[:disable_proxy]
          request.logger.info "Disabled - #{url}"
          return [503, {}, nil]
        end
        retry_count = 3
        begin
          request.logger.info "Fetching - #{url}"
          res = Net::HTTP.get_response(settings.opt[:destination_host], path, settings.opt[:destination_port])
          unless res.code == '200'
            request.logger.info "Fetch failed - #{url}"
            return [503, {}, nil]
          end
        rescue
          retry_count -= 1
          if retry_count > 0
            request.logger.info "Retry fetching - #{url}"
            retry
          else
            request.logger.info "Fetch failed - #{url}"
            return [503, {}, nil]
          end
        end
        mem_cache.write(key, res)
        file_cache.write(key, res)
      else
        request.logger.info "Cache hit - #{url}"
      end
      headers = res.to_hash.inject({}){|hash, kv|
        key, val = kv
        hash[key] = val[0]
        hash
      }
      headers.delete("transfer-encoding")
      headers.delete("content-length")
      unless settings.opt[:wait_sec].nil?
        sleep settings.opt[:wait_sec].to_f
      end
      [res.code.to_i, headers, res.body]
    end

  end

end
