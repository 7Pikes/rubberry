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
      if loaded?
        size ? collection.first(size) : collection.first
      else
        col = limit(size || 1).collection
        size ? col.first(size) : col.first
      end
    end

    def count
      loaded? ? collection.size : count_response
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

    def delete_all
      delete_all_response
    end

    def loaded?
      !!@response
    end

    def collection
      @collection ||= (criteria.none? || response == {} ? [] : response['hits']['hits']).map do |doc|
        model.instantiate(doc)
      end
    end

    private

    def count_response
      @count_response ||= instrument('count_query.rubberry', count_request) do
        begin
          criteria.none? ? 0 : model.connection.count(count_request)['count']
        rescue Elasticsearch::Transport::Transport::Errors::NotFound => e
          raise e if e.message !~ /IndexMissingException/
          0
        end
      end
    end

    def reset
      super
      @response, @delete_all_response, @collection, @count_response = nil
    end

    def response
      @response ||= instrument('search_query.rubberry', request) do
        begin
          model.connection.search(request)
        rescue Elasticsearch::Transport::Transport::Errors::NotFound => e
          raise e if e.message !~ /IndexMissingException/
          {}
        end
      end
    end

    def delete_all_response
      @delete_all_response ||= instrument('delete_query.rubberry', delete_all_request) do
        model.connection.delete_by_query(delete_all_request)
      end unless criteria.none?
    end

    def instrument(name, request_body, &block)
      ActiveSupport::Notifications.instrument(name, request: request_body, model: model, &block)
    end

    def count_request
      { index: model.index_name, type: types }.tap do |h|
        request_query = request[:body][:query]
        h[:body] = { query: request_query } if request_query
      end
    end
  end
end
