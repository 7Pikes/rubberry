module Rubberry
  module Fields
    class Base
      class ValueProxy < Proxy
      end

      class ArrayProxy < Proxy
        # TODO: override all methods that change internal state of array.
        # They should keep objects as proxy.
        def objectize(value)
          ::Array.wrap(value).flatten.map{|v| __field__.proxy(v, __field__) }
        end

        def elasticize
          return nil if __target__.nil?
          _target.map(&:elasticize)
        end
      end

      TYPES = %w{string object integer long short byte double float boolean date token_count binary}.freeze

      attr_reader :options, :name, :children

      def initialize(name, options = {})
        @default = options.delete(:default)
        @as_array = options.delete(:array)
        @options = options
        @name = name.to_s
        @children = []
      end

      def as_array?
        !!@as_array
      end

      def allow_any?
        !!options[:allow_any]
      end

      def default_value(object)
        return if @default.nil?
        @default.respond_to?(:call) ? execute_default_block(@default, object) : @default
      end

      def type_cast(value)
        as_array? ? ArrayProxy.new(value, self) : proxy(value, self)
      end

      def read_value(value, object)
        type_cast(defaultize(value, object))
      end

      def read_value_before_type_cast(value, object)
        defaultize(value, object)
      end

      def type
        self.class.name.demodulize.underscore.inquiry
      end

      def add(field)
        children << field
      end

      def multi_field?
        nested? && !type.object?
      end

      def nested?
        !children.empty?
      end

      def proxy(value, field)
        proxy_class.new(value, field)
      end

      def mappings_hash
        hash = options.deep_dup
        hash[multi_field? ? :fields : :properties] = child_mappings_hash if nested?
        { name => hash }
      end

      def generate_class_methods(context)
      end

      def generate_instance_methods(context)
        context.class_eval <<-SOURCE
          def #{name}
            read_attribute(#{name.inspect})
          end

          def highlighted_#{name}
            read_highlighted_attribute(#{name.inspect})
          end

          def #{name}=(value)
            write_attribute(#{name.inspect}, value)
          end

          def #{name}?
            !!read_attribute(#{name.inspect})
          end

          def highlighted_#{name}?
            !!read_highlighted_attribute(#{name.inspect})
          end

          def #{name}_before_type_cast
            read_attribute_before_type_cast(#{name.inspect})
          end

          def #{name}_default
            fields[#{name.inspect}].default_value(self)
          end
        SOURCE
      end

      protected

      def child_mappings_hash
        children.map(&:mappings_hash).inject(&:merge)
      end

      def defaultize(value, object)
        value.nil? ? default_value(object) : value
      end

      def execute_default_block(default, object)
        default.arity == 0 ? object.instance_exec(&default) : object.instance_exec(object, &default)
      end

      def proxy_class
        @proxy_class ||= self.class.const_get('ValueProxy')
      end
    end
  end
end

Rubberry::Fields.const_set('TokenCount', Class.new(Rubberry::Fields::Base))
