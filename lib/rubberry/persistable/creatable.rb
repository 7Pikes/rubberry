module Rubberry
  module Persistable
    module Creatable
      module Command
        def change_document_state!
          document.instance_exec do
            @previously_changed = changes
            @changed_attributes.clear
            @new_record = false
          end
        end

        def attributes
          document.elasticated_attributes.tap do
            options[:ttl] = document.class.document_ttl if document.class.document_ttl? && !options.has_key?(:ttl)
          end
        end
      end

      extend ActiveSupport::Concern

      module ClassMethods
        def create(attributes, options = {})
          object = new(attributes)
          object.save(options)
          object
        end
      end

      private

      def create_document(options = {})
        Commands.build('Create', self, options).perform
      end
    end
  end
end
