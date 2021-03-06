require_relative 'outputter/table'
require_relative 'outputter/json'

module CloudConductorCli
  module Helpers
    module Outputter
      def output(response)
        outputter.output(response)
      end

      def outputter
        klass = Outputter.const_get(options[:format].to_s.camelize.to_sym)
        @outputter ||= klass.new
      end

      def message(message, indent_level: 0, indent_spaces: 2)
        outputter.message(' ' * indent_spaces * indent_level + message)
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
