module Rubberry
  module Persistable
    module Metadatable
      METADATA = %w{_id _version}.freeze

      METADATA.each do |name|
        class_eval <<-SOURCE.strip_heredoc
          def #{name}
            @#{name}
          end
        SOURCE
      end

      def update_metadata!(metadata)
        metadata.stringify_keys!
        metadata.slice(*METADATA).each do |ivar, value|
          instance_variable_set(:"@#{ivar}", value)
        end
      end
    end
  end
end
