require 'cloud_conductor_cli/version'
require 'active_support/dependencies'

module CloudConductorCli
  ActiveSupport::Dependencies.autoload_paths << File.expand_path('.', File.dirname(__FILE__))
end
