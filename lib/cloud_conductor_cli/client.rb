require 'thor'

module CloudConductorCli
  class Client < Thor
    register Models::Cloud, 'cloud', 'cloud', 'Subcommand to manage clouds'
    register Models::Pattern, 'pattern', 'pattern', 'Subcommand to manage patterns'
    register Models::System, 'system', 'system', 'Subcommand to manage systems'
    register Models::Application, 'application', 'application', 'Subcommand to manage applications'

    desc 'version', 'Show version number'
    def version
      puts "CloudConductor CLI Version #{VERSION}"
    end
    map %w(-v --version) => :version
  end
end
