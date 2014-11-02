module Rubberry
  module Operations
    class AtomicIncrement < Base
      alias :model :document

      attr_reader :operation, :counters

      def initialize(model, options = {})
        @options = options
        @document = model
        @operation = options.delete(:operation) || '+'
        @counters = options.delete(:counters)
        @counters = [counters] unless counters.respond_to?(:each)
      end

      def perform
        update_document
      rescue Elasticsearch::Transport::Transport::Errors::NotFound => e
        raise DocumentNotFound.new("Couldn't find #{model.name} with an ID (#{document_id})")
      rescue Elasticsearch::Transport::Transport::Errors::BadRequest => e
        raise e if e.message !~ /dynamic scripting disabled/
        raise DynamicScriptingDisabled.new
      end

      private

      def document_id
        options[:id]
      end

      def request
        { index: model.index_name, type: model.type_name, body: attributes }.merge(options)
      end

      def update_document
        connection.update(request)
      end

      def attributes
        { script: update_scripts.join('; ') }
      end

      def update_scripts
        counters.map do |counter, value|
          value = normalize_value(value)
          "if(isdef ctx._source.#{counter}){ ctx._source.#{counter} += #{value} } " \
          "else { ctx._source.#{counter} = #{value} }"
        end
      end

      def normalize_value(value)
        value ||= 1
        value = -value if operation == '-'
        value
      end
    end
  end
end
