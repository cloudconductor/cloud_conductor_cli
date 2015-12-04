require 'thor'

module CloudConductorCli
  module Models
    module Base
      include Helpers::Record
      include Helpers::Input
      include Helpers::Outputter

      def self.included(klass)
        if klass.respond_to?(:superclass) && klass.superclass == Thor
          klass.class_option :host, aliases: '-H', type: :string,
                                    desc: 'CloudConductor server host. use CC_HOST environment if not specified.'
          klass.class_option :port, aliases: '-p', type: :string,
                                    desc: 'CloudConductor server port. use CC_PORT environment if not specified.'
          klass.class_option :format, aliases: '-f', type: :string, default: 'table',
                                      desc: 'Output format(table / json). use table format if not specified.'
        end
      end

      def initialize(args = [], options = {}, config = {})
        if config.key?(:current_command)
          current_command = config[:current_command]

          env_options = {}
          self.class.commands[current_command.name].options.keys.each do |key|
            env_options[key] = ENV["CC_#{key.to_s.upcase}"] if ENV["CC_#{key.to_s.upcase}"]
          end

          if options.is_a?(Array)
            array_options, hash_options = options, env_options

            parse_options = self.class.class_options
            command_options = config.delete(:command_options)
            parse_options = parse_options.merge(command_options) if command_options

            stop_on_unknown = self.class.stop_on_unknown_option? config[:current_command]
            opts = Thor::Options.new(parse_options, hash_options, stop_on_unknown)
            options = opts.parse(array_options)
          else
            options = env_options.merge(options)
          end
        end

        super(args, options, config)
      end
    end
  end
end
