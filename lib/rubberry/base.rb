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
    include Persistable
    include Expirable
    include Validations

    class_attribute :_index_name, instance_reader: false, instance_writer: false
    class_attribute :_type_name, instance_reader: false, instance_writer: false
    class_attribute :_document_ttl, instance_reader: false, instance_writer: false

    cattr_accessor :_all_registered_models
    self._all_registered_models = []

    class << self
      def inherited(subclass)
        _all_registered_models << subclass
        super
      end

      def inherited_models
        _all_registered_models.select{|m| m < self }.map(&:name).uniq.map(&method(:safe_constantize)).compact
      end

      def abstract!
        @abstract = true
      end

      def abstract?
        !!@abstract
      end

      def index_name(value = nil)
        if value
          self._index_name = value
        else
          build_index_name
        end
      end

      def type_name(value = nil)
        if value
          self._type_name = value
        else
          _type_name.try(:to_s).presence || default_type_name
        end
      end

      def document_ttl(value = nil)
        value ? (self._document_ttl = value) : _document_ttl
      end

      def document_ttl?
        !!document_ttl
      end

      def i18n_scope
        :rubberry
      end

      def context
        Context.new(self, types: type_name).version
      end

      def index
        @index ||= Index.new(index_name)
      end

      def default_index_name
        @default_index_name ||= begin
          names = model_name.collection.split(?/)
          names.size > 1 ? names[0...-1].join(?_).pluralize : names.first
        end
      end

      def default_type_name
        @default_type_name ||= model_name.element
      end

      private

      # rbx activesupport bug:
      # > 'Unknown::Class'.safe_constantize
      # NameError: Missing or uninitialized constant: Unknown
      # from kernel/common/module.rb:652:in `const_missing'
      def safe_constantize(class_name)
        class_name.constantize
      rescue NameError => e
        raise if e.name && !(class_name.to_s.split('::').include?(e.name.to_s) || e.name.to_s == class_name.to_s)
      end

      def build_index_name
        [config.index_namespace, self._index_name.presence || default_index_name].compact.join(?_)
      end
    end

    def ==(other)
      self.class == other.class && _id == other._id && _id.present?
    end
  end

  ActiveSupport.run_load_hooks(:rubberry, Base)
end

