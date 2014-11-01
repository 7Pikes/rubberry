# Rubberry

The ODM functionality for ElasticSearch documents. It works with ElasticSearch like with primary database, without any external models, such as ActiveRecord or Mongoid.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rubberry'
```

And then execute:

```
$ bundle
```

Or install it yourself as:

```
$ gem install rubberry
```

## Usage

### Configurations

At first, the `rubberry` looks into the `./config/rubberry.yml` file and merges this config with default config.

```yaml
development:
  # ElasticSearch::Client configurations
  # https://github.com/elasticsearch/elasticsearch-ruby/blob/master/elasticsearch-transport/lib/elasticsearch/transport/client.rb
  client:
    hosts: ['http://localhost:9200']

  # Index settings.
  # See: http://www.elasticsearch.org/guide/en/elasticsearch/reference/1.4//indices-update-settings.html
  # index:
  #   number_of_shards: 1
  #   number_of_replicas: 0

  # Default query compilation mode. `:must` by default.
  query_mode: :must

  # Default filter compilation mode. `:must` by default.
  filter_mode: :and

  # Default filter compilation mode. It is the same as `filter_mode` by default.
  post_filter_mode: nil

  # Refresh index after changing. Disabled by default.
  refresh: false

  # Threshold value for expiring of documents.
  # You can't destroy or update document that is almost expired.
  almost_expire_threshold: 5000

  # Prefix for index name
  index_namespace: <%= env %>

  # Enabling / disabling of dynamic scripting. Disabled by default.
  dynamic_scripting: false

  # Wait for specified status after any index changing. Disabled by default.
  wait_for_status: nil

  # Timeout for status waiting. It wait 30 seconds by default.
  wait_for_status_timeout: 30s

  # Separated connections for threads or not
  connection_per_thread: true
```

Also you can configure Rubberry by using `Rubberry.configure` method.

```ruby
Rubberry.configure do |c|
  c.wait_for_status = 'green'
  c.wait_for_status_timeout = '5s'
  c.refresh = true

  c.client.hosts = ['localhost:9250']
  c.client.log = false

  c.index.number_of_shards = 1
  c.index.number_of_replicas = 0
end
```

Furthermore, you are able to load more then one config file. They will be merged:

```
Rubberry.config.load!(Rails.root.join('config/rubberry.local.yml'))
```

Configuration from two files (`config/rubbery.yml` and `config/rubberry.local.yml`) will be merged together.

### Defining models

There is nothing here yet. Look at the code.

## Contributing

1. Fork it ( https://github.com/undr/rubberry/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
