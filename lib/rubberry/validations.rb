module Rubberry
  module Validations
    extend ActiveSupport::Concern

    module ClassMethods
      def create!(attributes, options = {})
        object = new(attributes)
        object.save!(options)
        object
      end
    end

    def save(options = {})
      perform_validations(options) ? super : false
    end

    def save!(options = {})
      perform_validations(options) ? super : raise(DocumentInvalid.new(self))
    end

    def valid?(context = nil)
      context ||= (new_record? ? :create : :update)
      result = super(context)
      errors.empty? && result
    end

    protected

    def perform_validations(options = {})
      options[:validate] == false || valid?(options[:context])
    end
  end
end
