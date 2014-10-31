module Rubberry
  module Stateful
    def initialize(*)
      super
      @new_record = true
      @destroyed = false
      @readonly = false
    end

    def init_with(*)
      @new_record = false
      @destroyed = false
      @readonly = false
    end

    def updatable?
      changed? && persisted? && !almost_expired?
    end

    def creatable?
      changed? && new_record?
    end

    def destroyable?
      persisted?
    end

    def readonly?
      @readonly
    end

    def readonly!
      @readonly = true
      self
    end

    def destroyed?
      @destroyed
    end

    def persisted?
      !(new_record? || destroyed?)
    end

    def new_record?
      @new_record
    end

    protected

    def updating
      return false unless updatable?

      yield elasticated_attributes.slice(*changed)

      @previously_changed = changes
      @changed_attributes.clear
      true
    end

    def creation
      return false unless creatable?
      attrs = elasticated_attributes
      attrs['_ttl'] = self.class.document_ttl if self.class.document_ttl

      yield attrs

      @previously_changed = changes
      @changed_attributes.clear
      @new_record = false
      true
    end

    def deletion
      return false unless destroyable?
      yield
      @destroyed = true
      true
    end
  end
end
