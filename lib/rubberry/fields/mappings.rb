module Rubberry
  module Fields
    class Mappings
      attr_reader :fields
      attr_accessor :model

      ROOT_SETTINGS = %w{index_analyzer search_analyzer date_detection numeric_detection}.freeze
      UNDERSCORED_FIELDS = %w{_all _analyzer _routing _index _size _timestamp _ttl}.freeze
      ACCESSABLE_UNDERSCORED_FIELDS = %w{_timestamp _ttl}

      def initialize(model)
        @model = model
        @fields = {}
        @stack = []

        @dynamic_date_formats = Set.new
        @dynamic_templates = Set.new
      end

      def initialize_clone(other)
        @fields = other.fields.clone
        @dynamic_date_formats = other.dynamic_date_formats.clone unless other.dynamic_date_formats.nil?
        @dynamic_templates = other.dynamic_templates.clone unless other.dynamic_templates.nil?

        ROOT_SETTINGS.each do |setting_name|
          value = other.send(setting_name)
          instance_variable_set("@#{setting_name}", value.clone) unless value.nil?
        end
      end

      ROOT_SETTINGS.each do |setting_name|
        define_method(setting_name) do |value = nil|
          if value.nil?
            instance_variable_get("@#{setting_name}")
          else
            instance_variable_set("@#{setting_name}", value)
          end
        end

        define_method("reset_#{setting_name}!") do
          instance_variable_set("@#{setting_name}", nil)
        end
      end

      UNDERSCORED_FIELDS.each do |field_name|
        define_method(field_name) do |value|
          underscored_fields[field_name.to_sym] = value.deep_symbolize_keys
        end
      end

      def ttl_enabled?
        ttl_option = underscored_fields[:_ttl]
        ttl_option && ttl_option[:enabled]
      end

      def timestamp_enabled?
        timestamp_option = underscored_fields[:_timestamp]
        timestamp_option && timestamp_option[:enabled]
      end

      def dynamic_template(name, definition)
        @dynamic_templates << { name => definition }
      end

      def dynamic_templates
        @dynamic_templates.to_a
      end

      def dynamic_date_formats
        @dynamic_date_formats.to_a
      end

      def date_formats(*values)
        @dynamic_date_formats.merge(values)
      end

      alias :date_format :date_formats

      def field(name, options = {}, &block)
        Fields.build(name, options, &block).tap do |field|
          add_field(field)
          nested(field, &block) if block_given?
        end
      end

      def field?(name)
        fields.key?(name.to_s)
      end

      def to_hash
        { model.type_name => mappings_hash }
      end

      private

      attr_reader :stack

      def add_field(field)
        if current_field
          current_field.add(field)
        else
          fields[field.name] = field
          field.generate_instance_methods(generated_instance_attributes_methods)
          field.generate_class_methods(generated_class_attributes_methods)
        end
      end

      def nested(field, &block)
        stack.push(field)
        instance_exec(&block)
      ensure
        stack.pop
      end

      def current_field
        stack.last
      end

      def mappings_hash
        { properties: properties }.tap do |h|
          h.merge!(underscored_fields)

          ROOT_SETTINGS.each do |setting_name|
            value = send(setting_name)
            h[setting_name.to_sym] = value unless value.nil?
          end

          h[:dynamic_date_formats] = dynamic_date_formats unless dynamic_date_formats.empty?
          h[:dynamic_templates] = dynamic_templates unless dynamic_templates.empty?
        end
      end

      def properties
        fields.values.map(&:mappings_hash).inject(&:merge)
      end

      def generated_class_attributes_methods
        @generated_class_attributes_methods ||= Module.new.tap{|proxy| model.send(:extend, proxy) }
      end

      def generated_instance_attributes_methods
        @generated_instance_attributes_methods ||= Module.new.tap{|proxy| model.send(:include, proxy) }
      end

      def underscored_fields
        @underscored_fields ||= model.document_ttl ? { _ttl: { enabled: true } } : {}
      end
    end
  end
end
