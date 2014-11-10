module Rubberry
  module Persistable
    module Updatable
      module Command
        def change_document_state!
          document.instance_exec do
            @previously_changed = changes
            @changed_attributes.clear
          end
        end

        def attributes
          document.elasticated_attributes.slice(*document.changed)
        end
      end

      extend ActiveSupport::Concern

      def update_attribute(attribute, value)
        self[attribute] = value
        save
      end

      def update_attributes(attributes)
        assign_attributes(attributes)
        save
      end

      private

      def update_document(options = {})
        Commands.build('Update', self, options).perform
      end
    end
  end
end
