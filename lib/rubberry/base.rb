module Rubberry
  class Base
    extend  ActiveModel::Naming
    extend  ActiveModel::Translation
    include ActiveModel::Validations
    include ActiveModel::Conversion
    include ActiveModel::Dirty

    include ConnectionManager::ConnectionHandling
    include Fields
    include Finders
    include Stateful
    include Persistence
    include Expirable
    include Validations

    class << self
      def index_name(value = nil)
        if value
          @index_name = build_index_name(value)
        else
          @index_name ||= build_index_name(model_name.collection.gsub('/', '_'))
        end
      end

      def type_name(value = nil)
        value ? (@type_name = value ) : (@type_name ||= model_name.singular)
      end

      def document_ttl(value = nil)
        value ? (@document_ttl = value) : @document_ttl
      end

      def i18n_scope
        :rubberry
      end

      def context
        Context.new(self, types: type_name).version
      end

      def index
        @index ||= Index.new(self)
      end

      private

      def build_index_name(name)
        [config.index_namespace, name].compact.join(?_)
      end
    end

    def ==(other)
      self.class == other.class && _id == other._id && _id.present?
    end
  end

  ActiveSupport.run_load_hooks(:rubberry, Base)
end

