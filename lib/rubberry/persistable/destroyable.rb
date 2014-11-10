module Rubberry
  module Persistable
    module Destroyable
      module Command
        def change_document_state!
          document.instance_exec do
            @destroyed = true
          end
        end
      end

      extend ActiveSupport::Concern

      module ClassMethods
        def delete_all(options = {})
          Commands.build('DeleteAll', context, options).perform
        end
      end

      def delete(options = {})
        Commands.build('Delete', self, options).perform
      end
    end
  end
end
