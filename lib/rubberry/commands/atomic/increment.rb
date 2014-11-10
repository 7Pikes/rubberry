module Rubberry
  module Commands
    module Atomic
      class Increment < Base
        include Persistable::Incrementable::Command

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

        attr_reader :model

        def initialize(model, options = {})
          @model = model
          super(options)
        end

        def perform
          update_document
        rescue Elasticsearch::Transport::Transport::Errors::NotFound => e
          raise DocumentNotFound.new("Couldn't find #{model.name} with an ID (#{document_id})")
        rescue Elasticsearch::Transport::Transport::Errors::BadRequest => e
          raise e if e.message !~ /dynamic scripting disabled/
          raise DynamicScriptingDisabled.new
        end

        def request
          { index: model.index_name, type: model.type_name, body: attributes }.merge(request_options)
        end

        protected

        def request_option_keys
          optionable_validators.keys - [:operation, :counters]
        end

        private

        def document_id
          options[:id]
        end

        def update_document
          connection.update(request)
        end
      end
    end
  end
end
