$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
ENV['RACK_ENV'] = 'test'
require 'rubberry'
require 'timecop'
require 'pp'
require "codeclimate-test-reporter"

CodeClimate::TestReporter.start

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

  config.around :each do |example|
    begin
      old_tz, ENV['TZ'] = ENV['TZ'], 'Etc/UTC'
      example.run
    ensure
      old_tz ? ENV['TZ'] = old_tz : ENV.delete('TZ')
    end
  end

  config.around :each, index_model: ->(v){ v.is_a?(String) || v.is_a?(Class) } do |example|
    indices = Array.wrap(example.metadata[:index_model]).map{|model| model.index_name }.
      uniq.map{|index| Rubberry::Index.new(index) }

    indices.map(&:reset)
    example.run
    indices.map(&:delete)
  end

  config.around :each, time_freeze: ->(v){ v.is_a?(Date) || v.is_a?(Time) || v.is_a?(String) } do |example|
    datetime = if example.metadata[:time_freeze].is_a?(String)
      DateTime.parse(example.metadata[:time_freeze])
    else
      example.metadata[:time_freeze]
    end

    Timecop.freeze(datetime){ example.run }
  end
end
