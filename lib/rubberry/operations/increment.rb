module Rubberry
  module Operations
    class Increment < Base
      attr_accessor :counters, :operation

      def initialize(document, options = {})
        @options = options
        @document = document
        options[:refresh] = config.refresh unless options.has_key?(:refresh) && config.refresh?
        @atomic = options.delete(:atomic)
        @counters = options.delete(:counters)
        @operation = options.delete(:operation) || '+'
      end

      def perform
        if atomic? && config.dynamic_scripting?
          model.send(update_method, document._id, counters, options)
          document.reload
        else
          self.counters = [counters] unless counters.respond_to?(:each)
          counters.each do |counter, value|
            document[counter] ||= 0
            document[counter] += normalize_value(value)
          end
          document.save(options)
        end
        true
      end

      private

      def normalize_value(value)
        value ||= 1
        value = -value if operation == '-'
        value
      end

      def atomic?
        !!@atomic
      end

      def update_method
        operation == '-' ? :decrement : :increment
      end
    end
  end
end
