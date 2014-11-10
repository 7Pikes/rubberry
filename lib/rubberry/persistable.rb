require 'rubberry/persistable/metadatable'
require 'rubberry/persistable/creatable'
require 'rubberry/persistable/savable'
require 'rubberry/persistable/updatable'
require 'rubberry/persistable/incrementable'
require 'rubberry/persistable/destroyable'

module Rubberry
  module Persistable
    extend ActiveSupport::Concern

    included do
      include Metadatable
      include Creatable
      include Savable
      include Updatable
      include Incrementable
      include Destroyable
    end

    module ClassMethods
      def instantiate(doc)
        allocate.init_with(doc)
      end
    end

    def init_with(doc)
      update_metadata!(doc)
      @attributes = initialize_attributes
      assign_attributes(doc['_source'])
      (@changed_attributes || {}).clear
      (@previously_changed || {}).clear
      @highlighted_attributes = doc['highlight'] if doc.has_key?('highlight')
      super
      self
    end

    def reload
      init_with(connection.get(index: self.class.index_name, type: self.class.type_name, id: _id, refresh: true))
    rescue Elasticsearch::Transport::Transport::Errors::NotFound => e
      raise DocumentNotFound.new("Couldn't find #{name} with an ID (#{_id})")
    end
  end
end
