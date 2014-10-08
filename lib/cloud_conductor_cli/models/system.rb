require 'thor'

module CloudConductorCli
  module Models
    class System < Thor
      include Models::Base

      desc 'list', 'List systems'
      def list
        response = connection.get('/systems')
        error_exit('Failed to get systems') unless response.success?
        display_list(JSON.parse(response.body), except: %w(template_parameters parameters))
      end

      desc 'show SYSTEM_ID', 'Show system details'
      def show(id)
        response = connection.get("/systems/#{id}")
        error_exit('Specified record does not exist.') if response.status == 404
        error_exit("Failed to get system information. returns #{response.status}") unless response.success?
        display_details(JSON.parse(response.body))
      end

      desc 'create', 'Create system from patterns'
      method_option :name, type: :string, required: true, desc: 'System name'
      method_option :domain, type: :string, required: true, desc: 'Domain name to designate this system'
      method_option :patterns, type: :string, required: true, desc: 'Pattern names to build system'
      method_option :clouds, type: :array, required: true, desc: 'Cloud names to build system. First cloud is primary.'
      method_option :parameter_file, type: :string,
                                     desc: 'Load pattern parameters from json file. If this option does not specified, ' \
                                           'open interactive shell to answer parameters.'
      method_option :user_attribute_file, type: :string, desc: 'Load additional chef attributes from json file'
      def create
        payload = {
          name: options['name'],
          domain: options['domain'],
          clouds: clouds_with_priority(options['clouds']),
          stacks: stacks(options)
        }
        response = connection.post('/systems', payload)
        error_exit("Failed to register systems. returns #{response.status}") unless response.success?
        display_message 'Create acceppted. Provisioning system to specified cloud.'
        display_details(JSON.parse(response.body))
      end

      desc 'update SYSTEM_ID', 'Update system'
      method_option :name, type: :string, desc: 'System name'
      method_option :domain, type: :string, desc: 'Domain name to designate this system'
      method_option :patterns, type: :array, required: true, desc: 'Platform pattern name to build core system'
      method_option :clouds, type: :array, desc: 'Cloud names to build system. First cloud is primary.'
      method_option :parameter_file, type: :string,
                                     desc: 'Load parameters from file. If this option does not specified, ' \
                                           'open interactive shell to answer parameters.'
      method_option :user_attribute_file, type: :string, desc: 'Load additional chef attributes from json file'
      def update(id)
        payload = {}
        payload[:name] = options['name'] if options['name']
        payload[:domain] = options['domain'] if options['domain']
        payload[:clouds] = clouds_with_priority(options['clouds']) if options['clouds']
        payload[:stacks] = stacks(options) if options['parameter_file'] || options['user_attribute_file']
        response = connection.put("/systems/#{id}", payload)
        error_exit("Failed to update system. returns #{response.status}") unless response.success?
        display_message 'Update completed successfully.'
        display_details(JSON.parse(response.body))
      end

      desc 'delete SYSTEM_ID', 'Delete system'
      def delete(id)
        response = connection.delete("/systems/#{id}")
        error_exit('Specified system record does not exist.') if response.status == 404
        error_exit("Failed to delete system record. returns #{response.status}") unless response.success?
        display_message 'Delete completed successfully.'
      end
    end
  end
end
