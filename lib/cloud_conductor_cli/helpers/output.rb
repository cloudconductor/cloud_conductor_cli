require 'formatador'

module CloudConductorCli
  module Helpers
    module Output
      def display_message(message, indent_level: 0, indent_spaces: 2)
        indent = ' ' * indent_level * indent_spaces
        puts indent + message
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

      def error_exit(message, exit_code = 1)
        warn "Error: #{message}"
        exit exit_code
      end

      def normal_exit(message = nil, exit_code = 0)
        display_message message if message
        exit exit_code
      end
    end
  end
end
