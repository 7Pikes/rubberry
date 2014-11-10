require 'rubberry/commands/base'
require 'rubberry/commands/common'
require 'rubberry/commands/bulk'
require 'rubberry/commands/create'
require 'rubberry/commands/update'
require 'rubberry/commands/increment'
require 'rubberry/commands/atomic/increment'
require 'rubberry/commands/delete'
require 'rubberry/commands/delete_all'
require 'rubberry/commands/query'
require 'rubberry/commands/count_query'

module Rubberry
  module Commands
    extend self

    BULKABLE_COMMANDS = %w{Create Update Delete Increment}

    def build(type, document, options = {})
      command_class(type).new(document, options)
    end

    private

    def command_class(type)
      prefix = if Rubberry.bulk? && BULKABLE_COMMANDS.include?(type)
        'Rubberry::Commands::Bulk'
      else
        'Rubberry::Commands'
      end

      "#{prefix}::#{type}".constantize
    end
  end
end
