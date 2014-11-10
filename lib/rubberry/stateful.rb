module Rubberry
  module Stateful
    def initialize(*)
      super
      @new_record = true
      @destroyed = false
      @readonly = false
      @bulked = false
    end

    def init_with(*)
      @new_record = false
      @destroyed = false
      @readonly = false
      @bulked = false
    end

    def bulked?
      @bulked
    end

    def updatable?
      changed? && persisted? && !almost_expired?
    end

    def creatable?
      changed? && new_record? && !bulked?
    end

    def destroyable?
      persisted? && !bulked?
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
  end
end
