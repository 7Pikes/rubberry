module Rubberry
  module Commands
    class DeleteAll < Base
      option(:consistency).allow(:one, :quorum, :all, 'one', 'quorum', 'all')
      option(:replication).allow(:sync, :async, 'sync', 'async')
      option(:timeout).allow(Optionable.any(String), Optionable.any(Integer))

      attr_reader :context

      def initialize(context, options = {})
        @context = context
        super(options)
      end

      def perform
        connection.delete_by_query(request) unless context.criteria.none?
        true
      end

      def request
        context.delete_all_request.merge(request_options)
      end

      protected

      def change_options(options)
      end
    end
  end
end
