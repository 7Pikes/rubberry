module Rubberry
  module Persistence
    extend ActiveSupport::Concern

    METADATA = %w{_id _version}.freeze

    module ClassMethods
      def increment(id, counters, options = {})
        options[:id] = id
        options[:counters] = counters
        Operations::Atomic::Increment.new(self, options).perform
      end

      def decrement(id, counters, options = {})
        options[:id] = id
        options[:operation] = '-'
        options[:counters] = counters
        Operations::Atomic::Increment.new(self, options).perform
      end

      def create(attributes, options = {})
        object = new(attributes)
        object.save(options)
        object
      end

      def instantiate(doc)
        allocate.init_with(doc)
      end
    end

    def init_with(doc)
      update_metadata!(doc)
      @attributes = initialize_attributes
      assign_attributes(doc['_source'])
      (@changed_attributes || {}).clear
      @highlighted_attributes = doc['highlight'] if doc.has_key?('highlight')
      super
      self
    end

    METADATA.each do |name|
      class_eval <<-SOURCE.strip_heredoc
        def #{name}
          @#{name}
        end
      SOURCE
    end

    def save(options = {})
      create_or_update(options)
    rescue DocumentInvalid, ReadOnlyDocument => e
      false
    end

    def save!(options = {})
      create_or_update(options)
    end

    def delete(options = {})
      Operations::Delete.new(self, options).perform
    end

    def increment(counters, options = {})
      options[:counters] = counters
      Operations::Increment.new(self, options).perform
    end

    def decrement(counters, options = {})
      options[:operation] = '-'
      options[:counters] = counters
      Operations::Increment.new(self, options).perform
    end

    def update_attribute(attribute, value)
      self[attribute] = value
      save
    end

    def update_attributes(attributes)
      assign_attributes(attributes)
      save
    end

    def reload
      init_with(connection.get(index: self.class.index_name, type: self.class.type_name, id: _id, refresh: true))
    rescue Elasticsearch::Transport::Transport::Errors::NotFound => e
      raise DocumentNotFound.new("Couldn't find #{name} with an ID (#{_id})")
    end

    def update_metadata!(metadata)
      metadata.stringify_keys!
      metadata.slice(*METADATA).each do |ivar, value|
        instance_variable_set(:"@#{ivar}", value)
      end
    end

    private

    def create_or_update(options = {})
      raise ReadOnlyDocument if readonly?
      new_record? ? create_document(options) : update_document(options)
    end

    def create_document(options = {})
      Operations::Create.new(self, options).perform
    end

    def update_document(options = {})
      Operations::Update.new(self, options).perform
    end
  end
end
