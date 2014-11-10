module Rubberry
  module Commands
    class Create < Base
      include Common
      include Persistable::Creatable::Command

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

      def request
        { index: model.index_name, type: model.type_name, body: attributes }.merge(request_options)
      end

      private

      def save_document
        connection.create(request)
      end
    end
  end
end
