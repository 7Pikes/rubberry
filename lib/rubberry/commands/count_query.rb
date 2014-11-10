module Rubberry
  module Commands
    class CountQuery < Base
      attr_reader :context

      def initialize(context, options = {})
        @context = context
      end

      def perform
        context.criteria.none? ? 0 : connection.count(request)['count']
      rescue Elasticsearch::Transport::Transport::Errors::NotFound => e
        raise e if e.message !~ /IndexMissingException/
        0
      end

      def request
        context.count_query_request
      end
    end
  end
end
