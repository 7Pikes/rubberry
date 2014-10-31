module Rubberry
  class Index
    attr_reader :model, :index_name, :type_name

    def initialize(model)
      @model = model
      @index_name = model.index_name
      @type_name = model.type_name
    end

    def create
      indices_api.create(index: index_name, body: { settings: model.config.index.to_h,  mappings: model.mappings_hash })
      Rubberry.wait_for_status
    end

    def get
      indices_api.get(index: index_name)
    end

    def get_mappings
      indices_api.get_mapping(index: index_name, type: type_name)
    end

    def delete
      indices_api.delete(index: index_name)
      Rubberry.wait_for_status
    end

    def refresh
      indices_api.refresh(index: index_name)
    end

    def delete_mappings
      indices_api.delete_mapping(index: index_name, type: type_name)
      Rubberry.wait_for_status
    end

    def exists?
      indices_api.exists(index: index_name)
    end

    def exists_type?
      indices_api.exists_type(index: index_name, type: type_name)
    end

    def reset
      delete
      create
    end

    def update_mappings
      indices_api.put_mapping(index: index_name, type: type_name, body: model.mappings_hash)
      Rubberry.wait_for_status
    end

    def indices_api
      model.connection.indices
    end
  end
end
