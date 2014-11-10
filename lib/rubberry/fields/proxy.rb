module Rubberry
  module Fields
    class Proxy < BasicObject
      SELF_METHODS = %w{objectize elasticize value_proxy?}

      class << self
        def new(target, field)
          case target
          when NilClass
            nil
          when FalseClass
            field.as_array? ? super : false
          else
            super
          end
        end
      end

      attr_reader :__target__

      def initialize(target, field)
        @__field__ = field
        @__target__ = objectize(target) unless target.nil?
      end

      def objectize(value)
        value
      end

      def elasticize
        __target__
      end

      def ==(other)
        super || equal_proxy?(other) || __target__ == other
      end

      def method_missing(method_name, *args, &block)
        __target__.respond_to?(method_name) ? __target__.send(method_name, *args, &block) : super
      end

      def respond_to_missing?(method_name, p = false)
        SELF_METHODS.include?(method_name.to_s) || __target__.respond_to?(method_name, p)
      end

      def respond_to?(method_name, p = false)
        SELF_METHODS.include?(method_name.to_s)
      end

      def value_proxy?
        true
      end

      private

      def equal_proxy?(other)
        other.value_proxy? && other.__target__ == __target__
      end

      attr_reader :__field__
    end
  end
end

class Object
  def value_proxy?
    false
  end
end

class NilClass
  def elasticize
    nil
  end
end

class FalseClass
  def elasticize
    false
  end
end

