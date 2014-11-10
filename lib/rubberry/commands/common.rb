module Rubberry
  module Commands
    module Common
      extend ActiveSupport::Concern

      included do
        attr_reader :document
      end

      def initialize(document, options = {})
        @document = document
        super(options)
      end

      protected

      def model
        document.class
      end
    end
  end
end
