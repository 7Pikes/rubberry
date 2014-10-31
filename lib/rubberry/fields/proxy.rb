module Rubberry
  module Fields
    class Proxy < BasicObject
      SELF_METHODS = %w{objectize elasticize value_proxy?}

      def initialize(target, field)
        @_field = field
        @_target = objectize(target) unless target.nil?
      end

      def objectize(value)
        value
      end

      def elasticize
        _target
      end

      def ==(other)
        _target == other
      end

      def method_missing(method_name, *args, &block)
        _target.respond_to?(method_name) ? _target.send(method_name, *args, &block) : super
      end

      def respond_to_missing?(method_name, p = false)
        SELF_METHODS.include?(method_name.to_s) || _target.respond_to?(method_name, p)
      end

      def respond_to?(method_name, p = false)
        SELF_METHODS.include?(method_name.to_s)
      end

      def value_proxy?
        true
      end

      private

      attr_reader :_target, :_field
    end
  end
end

class Object
  def value_proxy?
    false
  end
end
