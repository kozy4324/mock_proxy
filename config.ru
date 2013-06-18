# This file is used by Rack-based servers to start the application.
#\ --port 3333
require './lib/mock_proxy'
MockProxy::App[:cache_path] = './.cache'
run MockProxy::App
