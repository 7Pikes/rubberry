module Rubberry
  module Rspec
    module Helpers
      def stub_model(name, superclass = nil, &block)
        stub_class(name, superclass || Rubberry::Base, &block)
      end

      def stub_class(name, superclass = nil, &block)
        stub_const(name.to_s.camelize, Class.new(superclass || Object, &block))
      end

      def build_field(name, options = {}, &block)
        Rubberry::Fields.build(name, options, &block)
      end

      def root
        File.expand_path('../../../', File.dirname(__FILE__))
      end
    end
  end
end
