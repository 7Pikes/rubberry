module Rubberry
  module Commands
    class Bulk
      class Delete < Base
        include Common
        include Bulkable
        include Persistable::Destroyable::Command

        def request
          { type => { _index: model.index_name, _type: model.type_name, _id: document._id } }
        end

        private

        def performable?
          document.destroyable?
        end
      end
    end
  end
end
