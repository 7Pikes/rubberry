module Rubberry
  module Persistable
    module Incrementable
      module Command
        private

        def normalize_value(value)
          value ||= 1
          value = -value if operation == '-'
          value
        end

        def operation
          options[:operation] || '+'
        end

        def counters
          @counters ||= options[:counters].respond_to?(:each) ? options[:counters] : [options[:counters]]
        end

        # def attributes
        #   result = counters.each_with_object(params: {}, upsert: {}, script: []) do |(counter, value), result|
        #     value = normalize_value(value)
        #     result[:script] << "ctx._source.#{counter} += #{counter}"
        #     result[:params].merge!(counter => value)
        #     result[:upsert].merge!(counter => 0)
        #   end

        #   result[:script] = result[:script].join('; ')
        #   result
        # end

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

        def change_document_state!
          document.reload if respond_to?(:document)
        end
      end

      extend ActiveSupport::Concern

      module ClassMethods
        def increment(id, counters, options = {})
          options[:id] = id
          options[:counters] = counters
          Commands.build('Atomic::Increment', self, options).perform
        end

        def decrement(id, counters, options = {})
          options[:id] = id
          options[:operation] = '-'
          options[:counters] = counters
          Commands.build('Atomic::Increment', self, options).perform
        end
      end

      def increment(counters, options = {})
        options[:counters] = counters
        Commands.build('Increment', self, options).perform
      end

      def decrement(counters, options = {})
        options[:operation] = '-'
        options[:counters] = counters
        Commands.build('Increment', self, options).perform
      end
    end
  end
end
