module Rubberry
  class Index
    include ConnectionManager::ConnectionHandling

    attr_reader :index_name

    def initialize(index_name)
      @index_name = index_name
    end

    def create
      indices_api.create(
        index: index_name,
        body: { settings: config.index.to_h,  mappings: Rubberry.mappings_for(index_name) }
      )
      Rubberry.wait_for_status
    end

    def delete
      indices_api.delete(index: index_name)
      Rubberry.wait_for_status
    end

    def refresh
      indices_api.refresh(index: index_name)
    end

    def exists?
      indices_api.exists(index: index_name)
    end

    def reset
      delete rescue nil
      create
    end

    def indices_api
      connection.indices
    end
  end
end
