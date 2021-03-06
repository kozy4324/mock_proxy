# MockProxy

Super lightweight mock & proxy server.

## Installation

Add this line to your application's Gemfile:

    gem "mock_proxy", '>=0.0.1', :git => 'https://github.com/kozy4324/mock_proxy.git'

And then execute:

    $ bundle

## Usage

create `config.ru` as below.

    # This file is used by Rack-based servers to start the application.
    #\ --port 3333
    require 'mock_proxy'
    MockProxy::App[:cache_path] = './.cache'
    MockProxy::App[:destination_host] = 'kozy4324.github.io'
    MockProxy::App[:destination_port] = 80
    run MockProxy::App

run server.

    $ rackup config.ru

request server.

    $ curl http://localhost:3333/
    $ curl http://localhost:3333/blog/archives/

retrieved contents have been stored in file.

    $ tree .cache/
    .cache/
    ├── 909
    │   └── 970
    │       └── 87dc308737c37c6c518bb3d207f74942f41
    └── 9A7
        └── 3D0
            └── 6a3355733665303b6658af41478027b022d7d97c
    
    4 directories, 2 files

after being stored, server will never request destination server.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
