require 'thor'
require 'formatador'
require 'readline'
require 'faraday'
require 'json'

module CloudConductorCli
  module Base
    def self.included(klass)
      if klass.respond_to?(:superclass) && klass.superclass == Thor
        klass.class_option :host, aliases: '-H', type: :string,
                                  desc: 'CloudConductor server host. use CC_HOST environment if not specified.'
        klass.class_option :port, aliases: '-p', type: :string,
                                  desc: 'CloudConductor server port. use CC_PORT environment if not specified.'
      end
    end

    private

    def connection
      Connection.new(options[:host], options[:port])
    end

    def error_exit(message, exit_code = 1)
      warn "Error: #{message}"
      exit exit_code
    end

    def normal_exit(message = nil, exit_code = 0)
      display_message message if message
      exit exit_code
    end

    def input_template_parameters(pattern_names)
      parameters = pattern_parameters(pattern_names)
      input_parameters = parameters.each_with_object({}) do |(pattern_name, params), result|
        result[pattern_name] = read_input(pattern_name, params)
      end
      # JSON.dump(input_parameters)
      # TODO: Fix API
      JSON.dump(input_parameters.first.last.merge(operating_system: 'centos'))
    end

    def read_input(pattern_name, params)
      puts "Input #{pattern_name} Parameters"
      params.each_with_object({}) do |param, result|
        # next if param['description'].include?("This parameter is automatically filled by CloudConductor")
        next if param['description'].include?('ImageId')
        puts "  #{param['keyname']}: #{param['description']}"
        loop do
          input = Readline.readline("  Default [#{param['default']}] > ")
          input = param['default'] if !param['default'].nil? && (input.nil? || input.empty?)
          break if validate_parameter(param, input)
        end
        result[param['keyname']] = input
      end
    end

    def pattern_parameters(pattern_names)
      response = connection.get('/patterns')
      patterns = JSON.parse(response.body)
      pattern_names.each_with_object({}) do |pattern_name, result|
        pattern_id = patterns.find { |pattern| pattern['name'] == pattern_name }['id']
        response = connection.get("/patterns/#{pattern_id}/parameters")
        parameters = JSON.parse(response.body)
        result[pattern_name] = parameters
        result
      end
    end

    def validate_parameter(parameter, input)
      if parameter[:type]
        case parameter[:type]
        when 'String', 'CommaDelimitedList'
          return false unless input.is_a? String
        when 'Number'
          return false unless input.is_a? Fixnum
        end
      end
      true
    end

    def display_message(message)
      puts message
    end

    def display_list(data, except: nil)
      display_data = data
      display_data = filter(display_data, except) unless except.nil?
      if display_data.empty?
        display_message 'No records'
      else
        Formatador.display_compact_table(display_data, display_data.first.keys)
      end
    end

    def display_details(data, except: nil)
      display_data = data
      display_data = filter(display_data, except) unless except.nil?
      display_data = verticalize(display_data)
      Formatador.display_compact_table(display_data)
    end

    def verticalize(data)
      return data unless data.is_a? Hash
      data.map do |key, value|
        { property: key, value: value }
      end
    end

    def filter(data, exclude_keys)
      case data
      when Array
        data.map do |record|
          record.reject { |key, _value| exclude_keys.include?(key) }
        end
      when Hash
        data.reject { |key, _value| exclude_keys.include?(key) }
      else
        data
      end
    end
  end
end
