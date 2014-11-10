module Rubberry
  module Commands
    class Bulk
      class Increment < Base
        include Common
        include Bulkable
        include Persistable::Incrementable::Command

        option(:operation).allow(nil, '-', '+')
        option(:counters).allow(Optionable.any(Symbol), Optionable.any(String))
        option(:counters).allow(Optionable.any(Array), Optionable.any(Hash))
        option(:id).allow(Optionable.any(Object))

        option(:timestamp).allow(Optionable.any(Time), Optionable.any(DateTime))
        option(:ttl).allow(Optionable.any(String), Optionable.any(Integer))
        option(:_retry_on_conflict).allow(Optionable.any(Integer))

        def request
          { type => { _index: model.index_name, _type: model.type_name, _id: document._id, data: attributes }.
            merge(request_options) }
        end

        protected

        def change_options(options)
          options[:_retry_on_conflict] = options.delete(:retry_on_conflict) if options[:retry_on_conflict]
        end

        def request_option_keys
          optionable_validators.keys - [:operation, :counters, :id]
        end

        private

        def type
          'update'
        end

        def performable?
          document.destroyable?
        end
      end
    end
  end
end
