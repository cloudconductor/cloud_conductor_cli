require 'cloud_conductor_cli/version'
require 'active_support'
require 'active_support/dependencies'
require 'active_support/core_ext'

module CloudConductorCli
  ActiveSupport::Dependencies.autoload_paths << File.expand_path('.', File.dirname(__FILE__))
end
