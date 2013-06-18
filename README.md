# MockProxy

Super lightweight mock & proxy server.

## Installation

Add this line to your application's Gemfile:

    gem 'mock_proxy'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mock_proxy

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
    ├── 13C
    │   └── 110
    │       └── %2F%3F
    └── 76F
        └── 820
            └── %2Fblog%2Farchives%2F%3F
    
    4 directories, 2 files

after being stored, server will never request destination server.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
