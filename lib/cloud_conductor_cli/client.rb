require 'thor'

module CloudConductorCli
  class Client < Thor
    register Cloud, 'cloud', 'cloud', 'Subcommand to manage clouds'
    register Pattern, 'pattern', 'pattern', 'Subcommand to manage patterns'
    register System, 'system', 'system', 'Subcommand to manage systems'
    register Application, 'application', 'application', 'Subcommand to manage applications'

    desc 'version', 'Show version number'
    def version
      puts "CloudConductor CLI Version #{VERSION}"
    end
    map %w(-v --version) => :version
  end
end
