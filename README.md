# Parmesan

Parmesan parses HTTP/Rack (query / header / cookie) parameters exactly as described in an [OpenAPI](https://www.openapis.org/) definition. It supports `style`, `explode` and `schema` definitions according to OpenAPI 3.1.

Open question: What about path parameters?

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add parmesan

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install parmesan

## Synopsis

Note that OpenAPI supportes parameter definition on path and operation objects. Parameter definition must use strings as keys.

```ruby
parameter = Parmesan::Parameter.new({
  'name' => 'names',
  'required' => false,
  'in' => 'query',
  'explode' => false,
  'style' => 'form',
  'schema' => {
    'type' => 'array',
    'items' => {
      'type' => 'integer'
    }
  }
})
# Requet is GET /somewhere?names=1,2,3
request = Rack::Request.new(Rack::MockRequest.env_for('/somewhere?names=1,2,3'))
value = parameter.value(request) # => [1,2,3]
parameter.name # => 'names'
parameter.location # => 'query'
parameter.schema # => { 'type': 'array', { 'items' => { 'type' => 'integer' } } }
```

Currently this library does not validate the parameter value against it's JSON Schema.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ahx/parmesan.
