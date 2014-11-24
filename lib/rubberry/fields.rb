require 'rubberry/fields/mappings'
require 'rubberry/fields/proxy'
require 'rubberry/fields/base'

(Rubberry::Fields::Base::TYPES - %w{token_count}).each{|f| require "rubberry/fields/#{f}" }

module Rubberry
  module Fields
    extend ActiveSupport::Concern

    class << self
      def build(name, options = {}, &block)
        options[:type] = block_given? ? 'object' : 'string' if options[:type].blank?

        unless Fields::Base::TYPES.include?(options[:type])
          raise InvalidFieldType, "An `#{options[:type]}` is invalid type of a field"
        end

        klass = Fields.const_get(options[:type].classify, false)
        klass.new(name, options, &block)
      end
    end

    included do
      class_attribute :_mappings, instance_writer: false
      self._mappings = Mappings.new(self)

      delegate :has_field?, :initialize_attributes, :fields, to: 'self.class'
    end

    module ClassMethods
      def inherited(subclass)
        subclass._mappings = _mappings.clone
        subclass._mappings.model = subclass
        super
      end

      def mappings(&block)
        _mappings.instance_exec(&block)
      end

      def fields
        _mappings.fields
      end

      def has_field?(name)
        _mappings.field?(name.to_s)
      end

      def initialize_attributes
        Hash[fields.keys.zip]
      end

      def mappings_hash
        _mappings.to_hash
      end
    end

    def initialize(attributes = {})
      @attributes = initialize_attributes
      assign_attributes(attributes)
    end

    def write_attribute(name, value)
      name = name.to_s
      attribute_will_change!(name)
      attributes_cache.delete(name)
      @attributes[name] = value
    end

    alias :[]= :write_attribute

    def read_attribute(name)
      name = name.to_s
      if attributes_cache.key?(name)
        attributes_cache[name]
      else
        attributes_cache[name] = fields[name].read_value(@attributes[name], self)
      end
    end

    alias :[] :read_attribute

    def read_highlighted_attribute(name)
      highlighted_attributes[name.to_s]
    end

    def read_attribute_before_type_cast(name)
      name = name.to_s
      fields[name].read_value_before_type_cast(@attributes[name], self)
    end

    def elasticated_attributes
      initial_value = persisted? ? { '_id' => _id } : {}
      attribute_names.each_with_object(initial_value) do |name, result|
        result[name] = public_send(name).elasticize
      end
    end

    def attributes
      initial_value = persisted? ? { '_id' => _id } : {}
      attribute_names.each_with_object(initial_value){|name, result| result[name] = public_send(name) }
    end

    def attribute_names
      @attributes.keys
    end

    def assign_attributes(attributes)
      (attributes.presence || {}).each do |(name, value)|
        name = name.to_s
        public_send("#{name}=", value) if (has_field?(name) || respond_to?("#{name}=")) && name != '_id'
      end
    end

    alias :attributes= :assign_attributes

    private

    def highlighted_attributes
      @highlighted_attributes ||= {}
    end

    def attributes_cache
      @attributes_cache ||= {}
    end
  end
end
