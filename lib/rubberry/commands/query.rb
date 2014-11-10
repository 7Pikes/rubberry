module Rubberry
  module Commands
    class Query < Base
      attr_reader :context

      def initialize(context, options = {})
        @context = context
      end

      def perform
        connection.search(request)
      rescue Elasticsearch::Transport::Transport::Errors::NotFound => e
        raise e if e.message !~ /IndexMissingException/
        {}
      end

      def request
        context.request
      end
    end
  end
end
