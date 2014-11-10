module Rubberry
  class Context < ChewyQuery::Builder
    include Enumerable

    delegate :each, :size, to: :collection

    alias :to_ary :to_a
    alias :model :index

    def initialize(model, options = {})
      super(model, options.merge(
        query_mode: model.config.query_mode,
        filter_mode: model.config.filter_mode,
        post_filter_mode: model.config.filter_mode || model.config.post_filter_mode
      ))
    end

    def first(size = nil)
      collection = loaded? ? self.collection : limit(size || 1).collection
      size ? collection.first(size) : collection.first
    end

    def count
      loaded? ? collection.size : count_query_response
    end

    def facets(params = nil)
      params ? super(params) : response['facets'] || {}
    end

    def aggregations(params = nil)
      params ? super(params) : response['aggregations'] || {}
    end

    alias :aggs :aggregations

    def suggest(params = nil)
      params ? super(params) : response['suggest'] || {}
    end

    def took
      response['took']
    end

    def timed_out?
      response['timed_out']
    end

    def delete_all(options = {})
      Commands.build('DeleteAll', self, options).perform
    end

    def loaded?
      !!@response
    end

    def collection
      @collection ||= (criteria.none? || response == {} ? [] : response['hits']['hits']).map do |doc|
        model.instantiate(doc)
      end
    end

    def count_query_request
      { index: model.index_name, type: types }.tap do |h|
        request_query = request[:body][:query]
        h[:body] = { query: request_query } if request_query
      end
    end

    private

    def reset
      super
      @response, @collection, @count_query_response = nil
    end

    def count_query_response
      @count_query_response ||= Commands.build('CountQuery', self).perform
    end

    def response
      @response ||= Commands.build('Query', self).perform
    end
  end
end
