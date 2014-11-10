module Rubberry
  module Persistable
    module Savable
      def save(options = {})
        create_or_update(options)
      rescue DocumentInvalid, ReadOnlyDocument => e
        false
      end

      def save!(options = {})
        create_or_update(options)
      end

      private

      def create_or_update(options = {})
        raise ReadOnlyDocument if readonly?
        new_record? ? create_document(options) : update_document(options)
      end
    end
  end
end
