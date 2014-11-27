# Rubberry

The ODM functionality for ElasticSearch documents. It works with ElasticSearch like with primary database, without any external models, such as ActiveRecord or Mongoid.

[![Build Status](https://travis-ci.org/undr/rubberry.svg?branch=master)](https://travis-ci.org/undr/rubberry)
[![Code Climate](https://codeclimate.com/github/undr/rubberry/badges/gpa.svg)](https://codeclimate.com/github/undr/rubberry)
[![Test Coverage](https://codeclimate.com/github/undr/rubberry/badges/coverage.svg)](https://codeclimate.com/github/undr/rubberry)

## Why

Some people talk that it isn't good idea to use ElasticSearch as a primary database. Generally, they are right. But sometimes we need to have fast and temporary storage with strong search ability. That all about logs and events processing. 

Which do preconditions allow us to use ElasticSearch as a primary database?

- Needs in fast and rich search.
- Minimal changes of schema during life-cycle of an application. (To avoid reindex each deploy).
- Temporary or/and minor storage.

It has been written for events processing and is a kind of an experiment. 

You should use `chewy` or other 'ElasticSearch as index' solutions if you want to use it in tandem with another database.


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

```ruby
Rubberry.config.load!(Rails.root.join('config/rubberry.local.yml'))
```

Configuration from two files (`config/rubbery.yml` and `config/rubberry.local.yml`) will be merged together.

### Defining models

It's pretty easy. Define class inherited from `Rubberry::Base`. Define index name and index type if it necessary. Define mappings. That's all.

```ruby
class User < Rubberry::Base
  index_name :all_users
  type_name :user
  
  mappings do
    field :name
    field :email, analyzer: 'email'
    field :birthday, type: 'date', format: 'date', include_in_all: false
    field :tags, array: true, default: ['user']
    field :rating, type: 'integer', default: 0
    field :superhero, type: 'boolean', default: false
  end
  
  validates :email, :tags, presence: true
end
```

Fields options are the same as ES options, except two options: `:default` and `:array`. The `:default` option sets value by default, that will be stored in ES if no value assigned to field. The `:array` option defines array field. It means all values that assigned to this field will be changed to array.

```ruby
user = User.new(name: 'Undr', email: 'undr@server.com')
user.rating
# => 0
user.tags
# => ['user']
user.tags = 'super user'
user.tags
# => ['super user']
```

Also It's possible to define some metadata fields such as `_analyzer`, `_ttl` or `_timestamp` and root settings.
 
```ruby
class User < Rubberry::Base
  index_name :all_users
  type_name :user
  
  mappings do
    _ttl enabled: true, default: '8w'
    _timestamp enabled: true
    
    index_analyzer 'standard'
    search_analyzer 'standard'
    dynamic_template :template1,
      path_match: 'about.*',
      mappings: { type: 'string', analyzer: 'standard' }
    
    field :name
    field :email, analyzer: 'email'
    field :birthday, type: 'date', format: 'date', include_in_all: false
    field :tags, array: true, default: ['user']
    field :rating, type: 'integer', default: 0, index: false
    field :superhero, type: 'boolean', default: false, index: false
    
    # Field will accept hash values: user.about = { 'ru' => 'Реальный пацан', 'en' => 'Cool guy' }
    field :about, type: 'object' 
  end
  
  validates :email, :tags, presence: true
end
```
### CRUD operations

There is nothing here yet. Look at the code.

## Contributing

1. Fork it ( https://github.com/undr/rubberry/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
