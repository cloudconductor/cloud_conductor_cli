require 'readline'
require 'json'

module CloudConductorCli
  module Helpers
    module Input
      def input_template_parameters(blueprint_name)
        parameters = template_parameters(blueprint_name)
        read_user_inputs(parameters)
      end

      def read_user_inputs(parameters)
        parameters.each_with_object({}) do |(pattern_name, params), result|
          display_message "Input #{pattern_name} Parameters"
          result[pattern_name] = params.each_with_object({}) do |(key_name, options), inputs|
            display_message("#{key_name}: #{options['Description']}", indent_level: 1)
            input = nil
            loop do
              input = Readline.readline("  Default [#{options['Default']}] > ")
              input = options['Default'] if !options['Default'].nil? && (input.nil? || input.empty?)
              break if validate_parameter(options, input)
            end
            inputs[key_name] = input
          end
        end
      rescue Interrupt
        display_message "\n"
        exit
      end
    end
  end
end
