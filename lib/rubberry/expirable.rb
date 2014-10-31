module Rubberry
  module Expirable
    Fields::Mappings::ACCESSABLE_UNDERSCORED_FIELDS.each do |field_name|
      define_method(field_name) do
        return unless _mappings.ttl_enabled? || _mappings.timestamp_enabled?
        value = underscored_fields[field_name]
        value = Time.at(value / 1000) if field_name == '_timestamp' && value
        value
      end

      define_method("#{field_name}?") do
        return unless _mappings.ttl_enabled? || _mappings.timestamp_enabled?
        !!underscored_fields[field_name]
      end

      define_method("#{field_name}!") do
        return unless _mappings.ttl_enabled? || _mappings.timestamp_enabled?
        refresh_underscored_fields!
        value = underscored_fields[field_name]
        value = Time.at(value / 1000) if field_name == '_timestamp' && value
        value
      end
    end

    def almost_expired?
      return false unless _mappings.ttl_enabled?
      (_ttl! - config.almost_expire_threshold.to_i) <= 0
    end

    def expired?
      return false unless _mappings.ttl_enabled?
      _ttl! <= 0
    end

    def refresh_underscored_fields!
      @underscored_fields = nil
    end

    private

    def underscored_fields
      @underscored_fields ||= begin
        result = self.class.connection.get(
          id: _id,
          index: self.class.index_name,
          type: self.class.type_name,
          fields: Fields::Mappings::ACCESSABLE_UNDERSCORED_FIELDS.join(?,),
          refresh: config.refresh
        )
        (result['fields'] || {}).deep_stringify_keys
      rescue Elasticsearch::Transport::Transport::Errors::NotFound => e
        { '_ttl' => -Float::INFINITY }
      end
    end
  end
end
