module Rubberry
  module Operations
    class Delete < Base
      option(:refresh).allow(true, false)
      option(:consistency).allow(:one, :quorum, :all, 'one', 'quorum', 'all')
      option(:replication).allow(:sync, :async, 'sync', 'async')
      option(:timeout).allow(Optionable.any(String), Optionable.any(Integer))

      def perform
        return false unless document.destroyable?

        result = delete_document
        change_document_state!
        document.update_metadata!(_version: result['_version'])
        true
      end

      private

      def request
        { index: model.index_name, type: model.type_name, id: document._id }.merge(options)
      end

      def delete_document
        connection.delete(request)
      rescue Elasticsearch::Transport::Transport::Errors::NotFound => e
        { '_version' => document._version + 1 }
      end

      def change_document_state!
        document.instance_exec do
          @destroyed = true
        end
      end
    end
  end
end
