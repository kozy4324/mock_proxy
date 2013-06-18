# coding: utf-8

require 'sinatra/base'
require 'active_support/cache'

module MockProxy

  class App < Sinatra::Base

    file_cache = ActiveSupport::Cache::FileStore.new('./.cache')
    mem_cache = ActiveSupport::Cache::MemoryStore.new(:site => 32.megabytes)
    
    get /.*/ do
      cache_key = "#{request.path}?#{request.query_string}"
      mem_cache.fetch cache_key do
        file_cache.fetch cache_key do
          "Heeeeeeello\n"
        end
      end
    end

  end

end
