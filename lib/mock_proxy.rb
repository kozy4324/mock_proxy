# coding: utf-8

require 'sinatra/base'
require 'active_support/cache'

module MockProxy

  class App < Sinatra::Base

    set :opt, {
      :cache_path => './.cache',
      :mem_cache_size => 32.megabytes
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
      cache_key = "#{request.path}?#{request.query_string}"
      settings.mem_cache.fetch cache_key do
        settings.file_cache.fetch cache_key do
          "Heeeeeeello\n"
        end
      end
    end

  end

end
