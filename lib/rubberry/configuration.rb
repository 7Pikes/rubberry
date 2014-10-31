module Rubberry
  class Configuration

    OPTIONS = %w{wait_for_status wait_for_status_timeout dynamic_scripting index_namespace almost_expire_threshold
      refresh query_mode filter_mode post_filter_mode connection_per_thread}

    attr_reader :client_config, :index
    attr_accessor *OPTIONS

    def initialize
      @query_mode = :must
      @filter_mode = :and
      @refresh = false
      @index = OpenStruct.new
      @almost_expire_threshold = 5000
      @index_namespace = "#{env}"
      @dynamic_scripting = false
      @wait_for_status = nil
      @wait_for_status_timeout = '30s'
      @connection_per_thread = true
      @client_config = OpenStruct.new
      load!(config_root.join('rubberry.yml'))
    end

    def connection_per_thread?
      !!@connection_per_thread
    end

    private

    def load!(file, environment = env)
      assign_options!(yaml_options(file)[environment.to_sym])
    end

    def assign_options!(options = {})
      options = (options || {}).with_indifferent_access

      if value = options[:client]
        @client_config = OpenStruct.new(value.is_a?(String) ? { url: value } : OpenStruct.new(value))
      end

      if value = options[:index]
        @index = OpenStruct.new(value.presence || {})
      end

      options.slice(*OPTIONS).each{|key, value| send("#{key}=", value) }
    end

    def yaml_options(file)
      if File.exists?(file)
        yaml = ERB.new(File.read(file)).result
        YAML.load(yaml).try(:deep_symbolize_keys)
      else
        {}
      end
    end

    def env
      (defined?(Rails) ? Rails.env : ENV['RACK_ENV']) || 'development'
    end

    def config_root
      if defined?(Rails)
        Rails.root.join('config')
      else
        Pathname.new(Dir.pwd).join('config')
      end
    end
  end
end
