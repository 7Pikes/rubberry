module Rubberry
  module Persistence
    extend ActiveSupport::Concern

    module ClassMethods
      def increment(id, counters)
        update_counters(id, counters, '+')
      end

      def decrement(id, counters)
        update_counters(id, counters, '-')
      end

      def create(attributes)
        object = new(attributes)
        object.save
        object
      end

      def instantiate(doc)
        allocate.init_with(doc)
      end

      private

      def update_counters(id, counters, operation)
        result = []
        counters = [counters] unless counters.respond_to?(:each)
        counters.each do |counter, value|
          value = prepare_counter_value(value ||= 1, operation)
          result << "if(isdef ctx._source.#{counter}){ ctx._source.#{counter} += #{value} } " \
                    "else { ctx._source.#{counter} = #{value} }"
        end

        connection.update(
          index: index_name, type: type_name, id: id, body: { script: result.join('; ') }, refresh: config.refresh
        )
        true
      rescue Elasticsearch::Transport::Transport::Errors::NotFound => e
        raise DocumentNotFound.new("Couldn't find #{name} with an ID (#{id})")
      rescue Elasticsearch::Transport::Transport::Errors::BadRequest => e
        raise e if e.message !~ /dynamic scripting disabled/
        raise DynamicScriptingDisabled.new
      end

      def prepare_counter_value(value, operation)
        case
        when operation == '-' && !value.to_s.start_with?('-')
          "-#{value}"
        when operation == '-'
          value.to_s.gsub('-', '')
        else
          value
        end
      end
    end

    def init_with(doc)
      @id = doc['_id']
      @version = doc['_version']
      @attributes = initialize_attributes
      assign_attributes(doc['_source'])
      (@changed_attributes || {}).clear
      @highlighted_attributes = doc['highlight'] if doc.has_key?('highlight')
      super
      self
    end

    def _id
      @id
    end

    def _version
      @version
    end

    def save(*)
      create_or_update
    rescue DocumentInvalid, ReadOnlyDocument => e
      false
    end

    def save!(*)
      create_or_update
    end

    def delete
      deletion do
        begin
          result = connection.delete(
            index: self.class.index_name, type: self.class.type_name, id: _id, refresh: config.refresh
          )
          @version = result['_version']
        rescue Elasticsearch::Transport::Transport::Errors::NotFound => e
        end
      end
    end

    def increment(counters, options = {})
      if options.delete(:atomic) && config.dynamic_scripting?
        self.class.increment(_id, counters)
        reload
      else
        counters = [counters] unless counters.respond_to?(:each)
        counters.each do |counter, value|
          value ||= 1
          self[counter] ||= 0
          self[counter] += value
        end
        save
      end
    end

    def decrement(counters, options = {})
      if options.delete(:atomic) && config.dynamic_scripting?
        self.class.decrement(_id, counters)
        reload
      else
        counters = [counters] unless counters.respond_to?(:each)
        counters.each do |counter, value|
          value ||= 1
          self[counter] ||= 0
          self[counter] -= value
        end
        save
      end
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

    private

    def create_or_update
      raise ReadOnlyDocument if readonly?
      result = new_record? ? create_document : update_document
      result != false
    end

    def create_document
      creation do |attrs|
        connection.create(index: self.class.index_name, type: self.class.type_name, body: attrs).tap do |result|
          self.class.index.refresh if config.refresh?
          @id = result['_id']
          @version = result['_version']
        end
      end
    end

    def update_document
      updating do |attrs|
        begin
          result = connection.update(
            id: _id,
            index: self.class.index_name,
            type: self.class.type_name,
            body: { doc: attrs },
            refresh: config.refresh
          )

          @version = result['_version']
        rescue Elasticsearch::Transport::Transport::Errors::NotFound => e
          raise DocumentNotFound.new("Couldn't find #{name} with an ID (#{id})")
        end
      end
    end
  end
end
