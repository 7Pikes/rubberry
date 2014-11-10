module Rubberry
  module Commands
    class Bulk
      module Bulkable
        def perform
          return false unless performable?
          Rubberry.bulk << self
          change_bulked_state!
          true
        end

        def after_execute(result)
          result = result[type]

          if result.has_key?('error')
            change_bulked_state!(false)
            document.errors[:bulk] << result['error']
          else
            change_document_state!
            change_bulked_state!(false)
            document.update_metadata!(result)
          end

          document
        end

        private

        def change_options(options)
        end

        def type
          self.class.name.demodulize.downcase
        end

        def change_bulked_state!(flag = true)
          document.instance_exec(flag) do |flag|
            @bulked = flag
          end
        end
      end
    end
  end
end
