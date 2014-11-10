module Rubberry
  module Commands
    class Bulk
      class Update < Base
        include Common
        include Bulkable
        include Persistable::Updatable::Command

        option(:timestamp).allow(Optionable.any(Time), Optionable.any(DateTime))
        option(:ttl).allow(Optionable.any(String), Optionable.any(Integer))
        option(:_retry_on_conflict).allow(Optionable.any(Integer))

        def initialize(document, options = {})
          options[:_retry_on_conflict] = options.delete(:retry_on_conflict) if options[:retry_on_conflict]
          super
        end

        def request
          { type => {
            _index: model.index_name, _type: model.type_name, _id: document._id, data: { doc: attributes }
          }.merge(request_options) }
        end

        protected

        def change_options(options)
          options[:_retry_on_conflict] = options[:retry_on_conflict] if options[:retry_on_conflict]
        end

        private

        def performable?
          document.updatable?
        end
      end
    end
  end
end
