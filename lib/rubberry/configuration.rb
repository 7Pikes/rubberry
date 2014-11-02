module Rubberry
  class Configuration
    include Optionable

    attr_reader :client, :index, :options

    option(:query_mode).allow(:must, 'must')
    option(:query_mode).allow(:should, 'should')
    option(:query_mode).allow(:dis_max, 'dis_max')
    option(:query_mode).allow(Optionable.any(Numeric))

    option(:filter_mode).allow(:and, 'and')
    option(:filter_mode).allow(:or, 'or')
    option(:filter_mode).allow(:must, 'must')
    option(:filter_mode).allow(:should, 'should')
    option(:filter_mode).allow(:dis_max, 'dis_max')
    option(:filter_mode).allow(Optionable.any(Numeric))

    option(:post_filter_mode).allow(nil)
    option(:post_filter_mode).allow(:and, 'and')
    option(:post_filter_mode).allow(:or, 'or')
    option(:post_filter_mode).allow(:must, 'must')
    option(:post_filter_mode).allow(:should, 'should')
    option(:post_filter_mode).allow(:dis_max, 'dis_max')
    option(:post_filter_mode).allow(Optionable.any(Numeric))

    option(:wait_for_status).allow(nil)
    option(:wait_for_status).allow(:green, 'green')
    option(:wait_for_status).allow(:yellow, 'yellow')
    option(:wait_for_status).allow(:red, 'red')

    option(:wait_for_status_timeout).allow(nil, Optionable.any(Numeric), Optionable.any(String))

    option(:refresh).allow(true, false)

    option(:connection_per_thread).allow(true, false)

    option(:dynamic_scripting).allow(true, false)

    option(:index_namespace).allow(nil, Optionable.any(Symbol), Optionable.any(String))

    option(:almost_expire_threshold).allow(Optionable.any(Integer))

    optionable_validators.keys.each do |option_name|
      class_eval <<-SOURCE.strip_heredoc
        def #{option_name}
          options[#{option_name.inspect}]
        end

        def #{option_name}?
          !!options[#{option_name.inspect}]
        end

        def #{option_name}=(value)
          validate_strict(#{option_name}: value)
          options[#{option_name.inspect}] = value
        end
      SOURCE
    end

    def initialize
      @index = OpenStruct.new
      @client = OpenStruct.new
      @options = {
        query_mode: :must,
        filter_mode: :and,
        refresh: false,
        almost_expire_threshold: 5000,
        index_namespace: "#{env}",
        dynamic_scripting: false,
        wait_for_status: nil,
        wait_for_status_timeout: '30s',
        connection_per_thread: true
      }

      load!(config_root.join('rubberry.yml'))
    end

    def load!(file, environment = env)
      assign_options!(yaml_options(file)[environment.to_sym])
    end

    private

    def assign_options!(loaded_options = {})
      loaded_options = (loaded_options || {}).deep_symbolize_keys

      @client = parse_client_config(loaded_options.delete(:client)) if loaded_options[:client].present?
      @index = OpenStruct.new(loaded_options.delete(:index).presence || {}) if loaded_options[:index].present?

      loaded_options = loaded_options.slice(*optionable_validators.keys)
      validate_strict(loaded_options)
      options.merge!(loaded_options)
    end

    def yaml_options(file)
      if File.exists?(file)
        yaml = ERB.new(File.read(file)).result
        YAML.load(yaml).try(:deep_symbolize_keys)
      else
        {}
      end
    end

    def parse_client_config(value)
      case value
      when String
        OpenStruct.new(url: value)
      when Hash
        OpenStruct.new(value)
      else
        OpenStruct.new
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
