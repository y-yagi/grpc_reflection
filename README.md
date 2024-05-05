# GRPC::Reflection

[![CI](https://github.com/y-yagi/grpc_reflection/workflows/Ruby/badge.svg)](https://github.com/y-yagi/grpc_reflection/actions/workflows/main.yml)
[![Gem Version](https://badge.fury.io/rb/grpc_reflection.svg)](http://badge.fury.io/rb/grpc_reflection)

This gem aims to provide GRPC Server Reflection Protocol for Ruby. The main purpose is to allow using [grpcurl](https://github.com/fullstorydev/grpcurl).

Currently, only supports requests by　`file_containing_symbol` and `list_services`.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'grpc_reflection'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install grpc_reflection

## Usage

This gem provies the server for GRPC Server Reflection Protocol. Please add it to your GRPC server.

```ruby
s = GRPC::RpcServer.new
s.add_http2_port('0.0.0.0:50051', :this_port_is_insecure)
s.handle(GrpcReflection::Server)
s.run_till_terminated_or_interrupted([1, 'int', 'SIGTERM'])
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/y-yagi/grpc_reflection.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
