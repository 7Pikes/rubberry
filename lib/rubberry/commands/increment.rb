module Rubberry
  module Commands
    class Increment < Base
      include Common
      include Persistable::Incrementable::Command

      option(:atomic).allow(nil, true, false)
      option(:operation).allow(nil, '-', '+')
      option(:counters).allow(Optionable.any(Symbol), Optionable.any(String))
      option(:counters).allow(Optionable.any(Array), Optionable.any(Hash))


      option(:id).allow(Optionable.any(Object))
      option(:refresh).allow(true, false)
      option(:consistency).allow(:one, :quorum, :all, 'one', 'quorum', 'all')
      option(:replication).allow(:sync, :async, 'sync', 'async')
      option(:timestamp).allow(Optionable.any(Time), Optionable.any(DateTime))
      option(:timeout).allow(Optionable.any(String), Optionable.any(Integer))
      option(:ttl).allow(Optionable.any(String), Optionable.any(Integer))
      option(:retry_on_conflict).allow(Optionable.any(Integer))

      def perform
        if atomic? && config.dynamic_scripting?
          model.send(update_method, document._id, counters, request_options)
          change_document_state!
        else
          counters.each do |counter, value|
            document[counter] ||= 0
            document[counter] += normalize_value(value)
          end
          document.save(request_options)
        end
        true
      end

      protected

      def request_option_keys
        optionable_validators.keys - [:atomic, :operation, :counters]
      end

      private

      def atomic?
        !!options[:atomic]
      end

      def update_method
        operation == '-' ? :decrement : :increment
      end
    end
  end
end
