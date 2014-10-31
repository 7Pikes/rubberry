module Rubberry
  module Finders
    extend ActiveSupport::Concern

    CONTEXT_METHODS = %w{delete_all timeout count first explain version query_mode filter_mode post_filter_mode
      limit offset highlight rescore script_score boost_factor random_score field_value_factor decay suggest none
      strategy query filter post_filter boost_mode score_mode order reorder only only!}.freeze

    module ClassMethods
      delegate *CONTEXT_METHODS, to: :all

      def find(id)
        return nil if id.blank?
        id.is_a?(Array) ? find_many(id) : find_one(id)
      end

      def find!(id)
        raise DocumentNotFound.new("Couldn't find #{name} without an ID") if id.blank?
        id.is_a?(Array) ? find_many(id, strict: true) : find_one(id, strict: true)
      end

      def exists?(id)
        connection.exists(index: index_name, type: type_name, id: id, refresh: config.refresh)
      end

      def all
        context
      end

      private

      def find_many(ids, options = {})
        result = connection.mget(
          index: index_name, type: type_name, body: { ids: ids }, refresh: config.refresh
        )['docs']

        if !options[:strict]
          result.map{|doc| instantiate_found(doc) }
        else
          not_found_ids = result.reject{|doc| doc['found'] }.map{|doc| doc['_id'] }
          if not_found_ids.any?
            raise DocumentNotFound.new("Couldn't find #{name} with IDs (#{not_found_ids.join(', ')})")
          else
            result.map{|doc| instantiate(doc) }
          end
        end
      end

      def find_one(id, options = {})
        instantiate(connection.get(index: index_name, type: type_name, id: id, refresh: config.refresh))
      rescue Elasticsearch::Transport::Transport::Errors::NotFound => e
        !options[:strict] ? nil : (raise DocumentNotFound.new("Couldn't find #{name} with an ID (#{id})"))
      end

      def instantiate_found(doc)
        doc['found'] ? instantiate(doc) : nil
      end
    end
  end
end
