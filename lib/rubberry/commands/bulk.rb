module Rubberry
  module Commands
    class Bulk
      class Bunch
        include Optionable

        option(:refresh).allow(true, false)
        option(:consistency).allow(:one, :quorum, :all, 'one', 'quorum', 'all')
        option(:replication).allow(:sync, :async, 'sync', 'async')
        option(:timeout).allow(Optionable.any(String), Optionable.any(Integer))

        attr_reader :options

        delegate :map, :each, :empty?, :<<, to: :commands

        def initialize(options)
          options[:refresh] = Rubberry.config.refresh if Rubberry.config.refresh? && !options.has_key?(:refresh)
          validate_strict(options)
          @options = options
        end

        def commands
          @commands ||= []
        end
      end

      include ConnectionManager::ConnectionHandling

      class << self
        def instance=(value)
          Thread.current['[rubberry]:bulk_instance'] = value
        end

        def instance
          Thread.current['[rubberry]:bulk_instance'] ||= Commands::Bulk.new
        end
      end

      def perform(options = {})
        stack.push(Bunch.new(options))
        yield
        save_bunch unless bunch.empty?
      ensure
        stack.pop
      end

      def add(operation)
        bunch << operation
      end

      alias :<< :add

      def request
        bunch.options.merge(body: bunch.map(&:request))
      end

      def bunch
        stack.first
      end

      private

      def stack
        @stack ||= []
      end

      def save_bunch
        result = connection.bulk(request)
        bunch.map.with_index do |operation, index|
          operation.after_execute(result['items'][index])
        end
      end
    end
  end
end

require 'rubberry/commands/bulk/bulkable'
require 'rubberry/commands/bulk/create'
require 'rubberry/commands/bulk/delete'
require 'rubberry/commands/bulk/update'
require 'rubberry/commands/bulk/increment'
