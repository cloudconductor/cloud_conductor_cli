require 'readline'
require 'json'

module CloudConductorCli
  module Helpers
    module Input
      def input_template_parameters(blueprint_name, version)
        parameters = template_parameters(blueprint_name, version)
        read_user_inputs(parameters)
      end

      def read_user_inputs(parameters)
        parameters.each_with_object({}) do |(pattern_name, params), result|
          puts "Input #{pattern_name} Parameters"
          result[pattern_name] = {
            'cloud_formation' => {},
            'terraform' => {}
          }
          result[pattern_name]['cloud_formation'] = params['cloud_formation'].each_with_object({}) do |(key_name, options), inputs|
            inputs[key_name] = read_single_parameter(key_name, unify_options(options))
          end

          memorized_input = {}
          params['terraform'].keys.each do |cloud|
            result[pattern_name]['terraform'][cloud] = params['terraform'][cloud].each_with_object({}) do |(key_name, options), inputs|
              value = memorized_input[key_name] || read_single_parameter(key_name, unify_options(options))
              inputs[key_name] = value
              memorized_input[key_name] = value
            end
          end
        end
      rescue Interrupt
        puts "\n"
        exit
      end

      def read_single_parameter(key, options)
        puts "  #{key}: #{options[:description]}"
        value = loop do
          type = Readline.readline('  Type(static, module) > ')
          type = 'static' if  type.nil? || type.empty?
          next unless %w(static module).include? type

          input = Readline.readline("  Default [#{options[:default]}] > ")
          input = options[:default].to_s if options[:default] && (input.nil? || input.empty?)
          break { type: type, value: input } if validate_parameter(input, options)
        end
        puts
        value
      end

      def validate_parameter(input, options)
        return false if input.nil? || input.empty?
        case options[:type]
        when 'String', 'CommaDelimitedList'
          return false unless input.is_a? String
        when 'Number'
          Integer(input)
        end
        true
      rescue
        false
      end

      def unify_options(options)
        options.each_with_object({}) do |(key, value), results|
          results[key.downcase.to_sym] = value
        end
      end
    end
  end
end
