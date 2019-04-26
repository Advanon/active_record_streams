[![Build Status](https://travis-ci.org/Advanon/active_record_streams.svg?branch=master)](https://travis-ci.org/Advanon/active_record_streams)
[![Gem Version](https://badge.fury.io/rb/active_record_streams.svg)](https://badge.fury.io/rb/active_record_streams)

# Active Record Streams

A small library to stream ActiveRecord's create/update/delete
events to AWS SNS topics, Kinesis streams or HTTP listeners.

# Table of contents

* [Version mappings](#version-mappings)
* [Warning](#warning)
* [How does it work](#how-does-it-work)
* [Installation](#installation)
* [Usage](#usage)
  * [Setting up for AWS](#setting-up-for-aws)
  * [Enabling streams](#enabling-streams)
  * [Error handling](#error-handling)
* [Supported targets](#supported-targets)
* [License](#license)
* [Development](#development)
* [Contributing](#contributing)

## Version mappings

```
0.1.X - ActiveRecord 4.2.10
```

## Warning

Please, be aware that this library changes behaviour of such methods as
`update_all`, `delete_all`, `update_columns`, `update_column`
to start serving callbacks.

## How does it work

The library adds a global hook to the ActiveRecord's `after_commit`
events and streams these events to the specified targets (topics/streams/http).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'active_record_streams'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install active_record_streams

## Usage

### Setting up for AWS

Skip this section if you are not going to use any of AWS targets.

If you already configured AWS sdk or you are running the code under 
AWS-controlled environment with proper policies, ActiveRecordStreams
should start working without specifying any credentials.

If you didn't yet configure AWS globally or you want to specify separate
authentication details for streaming, use the following snippet:

```ruby
# config/initializers/active_record_streams.rb

require 'active_record_streams'

ActiveRecordStreams.configure do |config|
  config.aws_region = 'eu-central-1'
  config.aws_access_key_id = 'YOUR_ACCESS_KEY_ID'
  config.aws_secret_access_key = 'YOUR_SECRET_ACCESS_KEY'
end
```

### Enabling streams

To start streaming events you just need to add them to configuration.
You may add as many streams as you need. By default, each stream
publishes events for all the tables, but you may change that by specifying
the `table_name` or `ignored_tables` option.

```ruby
# config/initializers/active_record_streams.rb

require 'active_record_streams'

ActiveRecordStreams.configure do |config|
  # Listen to all tables and publish events to the specified SNS topic
  config.streams << ActiveRecordStreams::Publishers::SnsStream.new(
    topic_arn: 'arn:aws:sns:...'
  )
  
  # Publish only events coming from `users` table to the specified SNS topic
  config.streams << ActiveRecordStreams::Publishers::SnsStream.new(
    table_name: 'users',
    topic_arn: 'arn:aws:sns:...'
  )
  
  # Publish events for all the tables but `updates`
  config.streams << ActiveRecordStreams::Publishers::SnsStream.new(
    ignored_tables: %w[updates],
    topic_arn: 'arn:aws:sns:...'
  )
end
```

### Error handling

It might happen that the message delivery fails. In such case you might
want to retry sending the message or even use a background processor like
`Sidekiq` to perform retires in automated way.

Every stream has an `error_handler` option which accepts `lambda/proc`
with `error_handler :: (Stream, TableName, Message, Error) -> *` signature.

**NOTE** that your consumer has to take care of duplicated messages.
Each message contains `EventID` which may help to identify duplications.

```ruby
# config/initializers/active_record_streams.rb

require 'active_record_streams'

class SampleHttpReSender
  include Sidekiq::Worker
  
  def perform(table_name, message_json)
    message = ActiveRecordStreams::Message.from_json(message_json)
    ActiveRecordStreams.config.streams.each do |stream|
      stream.publish(table_name, message)
    end
  end
end

ActiveRecordStreams.configure do |config|
  config.streams << ActiveRecordStreams::Publishers::HttpStream.new(
    url: 'https://posteventshere.test',
    error_handler: lambda do |stream, table_name, message, error|
      # Do whatever you want here, you may also try to start a new
      # thread or re-try publishing directly to stream using
      # stream.publish(table_name, message)
 
      # Try to schedule re-publishing with Sidekiq 
      SampleHttpReSender.perform_async(table_name, message.json)
    end
  )
end
```

## Supported targets

### ActiveRecordStreams::Publishers::SnsStream

```ruby
config.streams << ActiveRecordStreams::Publishers::SnsStream.new(
  topic_arn: String,                  # Required
  table_name: String,                 # Optional
  ignored_tables: Enumerable<String>, # Optional

  # See: https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/SNS/Client.html#publish-instance_method
  overrides: {                        ## Optional
    target_arn: String,               #
    phone_number: String,             #
    subject: String,                  #
    message_structure: String,        #
    message_attributes: {             #
      'String' => {                   #
        data_type: String,            #
        string_value: String,         #
        binary_value: String          ##
      }
    }
  }
)
```

### ActiveRecordStreams::Publishers::KinesisStream

```ruby
config.streams << ActiveRecordStreams::Publishers::KinesisStream.new(
  stream_name: String,                # Required
  table_name: String,                 # Optional
  ignored_tables: Enumerable<String>, # Optional

  # See: https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/Kinesis/Client.html#put_record-instance_method
  overrides: {                             ## Optional
    explicit_hash_key: String,             #
    sequence_number_for_ordering: String,  ##
  }
)
```

### ActiveRecordStreams::Publishers::HttpStream

```ruby
config.streams << ActiveRecordStreams::Publishers::HttpStream.new(
  url: String,                        # Required
  headers: Hash,                      # Optional
  table_name: String,                 # Optional
  ignored_tables: Enumerable<String>  # Optional
)
```

## License

This software is licensed under the MIT license. See `MIT-LICENSE` for details.

## Development

1) Run `bundle install` to install dependencies
2) Use `rubocop` or `bundle exec rubocop` to run the Rubocop
3) Run `rspec` or `bundle exec rspec` to run the tests
4) Run `bundle exec rake install` to install the gem on a local machine
5) Do not forget to add your changes to the `CHANGELOG.md`
5) To release a new version update `version.rb`, `version_spec.rb` and run `gem build active_record_streams.gemspec` to release a new version
6) To push a new version to the Rubygems run `gem push <generated_gem_file.gem>`

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Advanon/active_record_streams.
