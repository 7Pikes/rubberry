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


      # def update_counters(id, counters, operation)
      #   result = []
      #   counters = [counters] unless counters.respond_to?(:each)
      #   counters.each do |counter, value|
      #     value = prepare_counter_value(value ||= 1, operation)
      #     result << "if(isdef ctx._source.#{counter}){ ctx._source.#{counter} += #{value} } " \
      #               "else { ctx._source.#{counter} = #{value} }"
      #   end

      #   connection.update(
      #     index: index_name, type: type_name, id: id, body: { script: result.join('; ') }, refresh: config.refresh
      #   )
      #   true
      # rescue Elasticsearch::Transport::Transport::Errors::NotFound => e
      #   raise DocumentNotFound.new("Couldn't find #{name} with an ID (#{id})")
      # rescue Elasticsearch::Transport::Transport::Errors::BadRequest => e
      #   raise e if e.message !~ /dynamic scripting disabled/
      #   raise DynamicScriptingDisabled.new
      # end

      # def prepare_counter_value(value, operation)
      #   case
      #   when operation == '-' && !value.to_s.start_with?('-')
      #     "-#{value}"
      #   when operation == '-'
      #     value.to_s.gsub('-', '')
      #   else
      #     value
      #   end
      # end
