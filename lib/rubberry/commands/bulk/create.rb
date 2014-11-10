module Rubberry
  module Commands
    class Bulk
      class Create < Base
        include Common
        include Bulkable
        include Persistable::Creatable::Command

        option(:timestamp).allow(Optionable.any(Time), Optionable.any(DateTime))
        option(:ttl).allow(Optionable.any(String), Optionable.any(Integer))

        def request
          { type => { _index: model.index_name, _type: model.type_name, data: attributes }.merge(request_options) }
        end

        private

        def performable?
          document.creatable?
        end
      end
    end
  end
end
