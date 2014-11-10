require 'yaml'
require 'chewy_query'
require 'active_model'
require 'optionable'
require 'elasticsearch'
require 'pp'

require 'rubberry/version'
require 'rubberry/extensions'
require 'rubberry/configuration'
require 'rubberry/connection_manager'
require 'rubberry/errors'
require 'rubberry/fields'
require 'rubberry/context'
require 'rubberry/finders'
require 'rubberry/stateful'
require 'rubberry/persistable'
require 'rubberry/commands'
require 'rubberry/expirable'
require 'rubberry/validations'
require 'rubberry/index'
require 'rubberry/base'

module Rubberry
  extend self

  def connection_manager
    Thread.main['[rubberry]:connection_manager'] ||= ConnectionManager.new
  end

  def configure
    yield config
  end

  def config
    @config ||= Configuration.new
  end

  def wait_for_status(options = {})
    if config.wait_for_status? || options[:status].present?
      request = { wait_for_status: config.wait_for_status || options[:status] }
      timeout = options[:timeout].presence  || config.wait_for_status_timeout
      request[:timeout] = timeout if timeout
      !connection_manager.connection.cluster.health(request)['timed_out']
    end
  end

  def bulk(options = {}, &block)
    block_given? ? Commands::Bulk.instance.perform(options, &block) : Commands::Bulk.instance
  end

  def bulk?
    !bulk.bunch.nil?
  end
end

ActiveSupport.on_load(:i18n) do
  I18n.load_path << File.dirname(__FILE__) + '/rubberry/locale/en.yml'
end

