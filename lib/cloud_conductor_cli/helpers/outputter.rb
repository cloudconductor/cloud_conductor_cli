require_relative 'outputter/table'
require_relative 'outputter/json'

module CloudConductorCli
  module Helpers
    module Outputter
      def output(response)
        klass = Output.const_get(options[:format].to_s.camelize.to_sym)
        @output ||= klass.new

        @output.output(response)
      end

      def display_message(message, indent_level: 0, indent_spaces: 2)
        indent = ' ' * indent_level * indent_spaces
        puts indent + message
      end

      def normal_exit(message = nil, exit_code = 0)
        puts message if message
        exit exit_code
      end

      def error_exit(message, response = nil, exit_code = 1)
        warn "Error: #{message}"
        warn "#{JSON.parse(response.body)['message']}" if response
        exit exit_code
      rescue JSON::ParserError
        warn response.body if response
        exit exit_code
      end
    end
  end
end
