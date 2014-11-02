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
require 'rubberry/operations'
require 'rubberry/persistence'
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

  def wait_for_status(timeout = nil)
    if config.wait_for_status?
      request = { wait_for_status: config.wait_for_status }
      timeout = timeout || config.wait_for_status_timeout
      request[:timeout] = timeout if timeout
      !connection_manager.connection.cluster.health(request)['timed_out']
    end
  end
end

ActiveSupport.on_load(:i18n) do
  I18n.load_path << File.dirname(__FILE__) + '/rubberry/locale/en.yml'
end
