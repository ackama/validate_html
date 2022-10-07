# ValidateHTML

Validate HTML as it leaves your rails application.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'validate_html'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install validate_html

## Usage

When included in your Gemfile, when in `development` & `test` environments ValidateHTML will automatically check html leaving your app via rack or html emails or turbo streams for invalid HTML using nokogiri.

To validate a block of HTML outside of these contexts (including outside of rails entirely), you can use
```ruby
ValidateHTML.validate_html(my_html_here, **options)
```

Full documentation: https://www.rubydoc.info/gems/validate_html

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ackama/validate_html.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
