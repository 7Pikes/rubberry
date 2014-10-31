module Rubberry
  class ConnectionManager
    module ConnectionHandling
      extend ActiveSupport::Concern

      def connection
        Rubberry.connection_manager.connection
      end

      def config
        Rubberry.config
      end

      module ClassMethods
        def connection
          Rubberry.connection_manager.connection
        end

        def config
          Rubberry.config
        end
      end
    end

    attr_reader :config, :lock

    def initialize(config = Rubberry.config)
      @config = config
      @lock = Mutex.new
    end

    def current_connection
      per_thread? ? Thread.current['[rubberry]:current_connection'] : @current_connection
    end

    def current_connection=(value)
      if per_thread?
        Thread.current['[rubberry]:current_connection'] = value
      else
        @current_connection = value
      end
    end

    def connection
      current_connection ||= synchronize do
        self.current_connection ||= Elasticsearch::Client.new(config.client_config)
      end
    end

    def resurrect_dead_connections!
      connection.transport.resurrect_dead_connections!
    end

    def reload_connections!
      connection.transport.reload_connections!
    end

    private

    def synchronize(&block)
      per_thread? ? block.call : lock.synchronize(&block)
    end

    def per_thread?
      config.connection_per_thread?
    end
  end
end
