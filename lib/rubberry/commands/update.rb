module Rubberry
  module Commands
    class Update < Base
      include Common
      include Persistable::Updatable::Command

      option(:refresh).allow(true, false)
      option(:consistency).allow(:one, :quorum, :all, 'one', 'quorum', 'all')
      option(:replication).allow(:sync, :async, 'sync', 'async')
      option(:timestamp).allow(Optionable.any(Time), Optionable.any(DateTime))
      option(:timeout).allow(Optionable.any(String), Optionable.any(Integer))
      option(:ttl).allow(Optionable.any(String), Optionable.any(Integer))
      option(:retry_on_conflict).allow(Optionable.any(Integer))

      def perform
        return false unless document.updatable?

        result = update_document
        change_document_state!
        document.update_metadata!(_version: result['_version'])
        true
      end

      def request
        { index: model.index_name, type: model.type_name, id: document._id, body: { doc: attributes } }.
          merge(request_options)
      end

      private

      def update_document
        connection.update(request)
      rescue Elasticsearch::Transport::Transport::Errors::NotFound => e
        raise DocumentNotFound.new("Couldn't find #{model.name} with an ID (#{document._id})")
      end
    end
  end
end
