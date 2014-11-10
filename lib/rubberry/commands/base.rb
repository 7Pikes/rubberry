module Rubberry
  module Commands
    class Base
      include Optionable
      include ConnectionManager::ConnectionHandling

      attr_reader :options

      def initialize(options = {})
        change_options(options)
        @options = options
        validate_strict(options)
      end

      def perform
      end

      def request_options
        options.slice(*request_option_keys)
      end

      protected

      def change_options(options)
        options[:refresh] = config.refresh unless options.has_key?(:refresh) && config.refresh?
      end

      def request_option_keys
        optionable_validators.keys
      end
    end
  end
end
