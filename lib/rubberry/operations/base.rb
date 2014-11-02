module Rubberry
  module Operations
    class Base
      include Optionable

      attr_reader :document, :options

      delegate :connection, :config, to: :document

      def initialize(document, options = {})
        validate_strict(options)
        @options = options
        @document = document
        options[:refresh] = config.refresh unless options.has_key?(:refresh) && config.refresh?
      end

      def perform
      end

      protected

      def model
        document.class
      end
    end
  end
end
