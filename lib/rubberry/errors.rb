module Rubberry
  class Error < StandardError
  end

  class InvalidFieldType < Error
  end

  class DocumentInvalid < Error
    attr_reader :document

    def initialize(document)
      @document = document
      errors = @document.errors.full_messages.join(', ')
      super(I18n.t(
        :"#{@document.class.i18n_scope}.errors.messages.document_invalid",
        errors: errors,
        default: :'errors.messages.document_invalid'
      ))
    end
  end

  class ReadOnlyDocument < Error
  end

  class DocumentNotFound < Error
  end

  class DynamicScriptingDisabled < Error
    def initialize
      msg = <<-MESSAGE.strip_heredoc
        Dynamic scripting is disabled by default in ElasticSearch since version 1.2.0.
        See for details: http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/modules-scripting.html#_enabling_dynamic_scripting
      MESSAGE
      super(msg)
    end
  end

  class DateTimeFormatError < Error
    def initialize(value, format_name, format)
      super("Value '#{value}' has invalid date format. Format: #{format_name}(#{format})")
    end
  end
end
