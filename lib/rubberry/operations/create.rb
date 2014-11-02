module Rubberry
  module Operations
    class Create < Base
      option(:refresh).allow(true, false)
      option(:consistency).allow(:one, :quorum, :all, 'one', 'quorum', 'all')
      option(:replication).allow(:sync, :async, 'sync', 'async')
      option(:timestamp).allow(Optionable.any(Time), Optionable.any(DateTime))
      option(:timeout).allow(Optionable.any(String), Optionable.any(Integer))
      option(:ttl).allow(Optionable.any(String), Optionable.any(Integer))

      def perform
        return false unless document.creatable?

        result = save_document
        change_document_state!
        document.update_metadata!(result)
        true
      end

      private

      def request
        { index: model.index_name, type: model.type_name, body: attributes }.merge(options)
      end

      def save_document
        connection.create(request)
      end

      def change_document_state!
        document.instance_exec do
          @previously_changed = changes
          @changed_attributes.clear
          @new_record = false
        end
      end

      def attributes
        document.elasticated_attributes.tap do
          options[:ttl] = document.class.document_ttl if document.class.document_ttl? && !options.has_key?(:ttl)
        end
      end
    end
  end
end
