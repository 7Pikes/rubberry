$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
ENV['RACK_ENV'] = 'test'
require 'rubberry'
require 'timecop'
require 'pp'

Dir['./spec/support/**/*.rb'].each{|f| require f }

Rubberry.configure do |c|
  c.wait_for_status = 'green'
  c.wait_for_status_timeout = '5s'
  c.refresh = true

  c.client.hosts = ['localhost:9250']
  c.client.log = false

  c.index.number_of_shards = 1
  c.index.number_of_replicas = 0
end

I18n.enforce_available_locales = false

RSpec.configure do |config|
  config.mock_with :rspec
  config.include Rubberry::Rspec::Helpers

  config.around :each, time_freeze: ->(v){ v.is_a?(Date) || v.is_a?(Time) || v.is_a?(String) } do |example|
    datetime = if example.metadata[:time_freeze].is_a?(String)
      DateTime.parse(example.metadata[:time_freeze])
    else
      example.metadata[:time_freeze]
    end

    Timecop.freeze(datetime){ example.run }
  end
end
