# This file is used by Rack-based servers to start the application.
#\ --port 3333
require './lib/mock_proxy'
MockProxy::App[:cache_path] = './.cache'
MockProxy::App[:destination_host] = 'kozy4324.github.io'
MockProxy::App[:destination_port] = 80
MockProxy::App[:disable_proxy] = false
MockProxy::App[:normalize_query] = Proc.new {|query| query.gsub(/random_\d+/, 'random') }
run MockProxy::App
