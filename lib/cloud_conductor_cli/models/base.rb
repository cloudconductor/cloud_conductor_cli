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
    end
  end
end
