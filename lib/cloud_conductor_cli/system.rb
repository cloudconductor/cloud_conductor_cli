require 'thor'

module CloudConductorCli
  class System < Thor
    include Base

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
    method_option :patterns, type: :array, required: true, desc: 'Platform pattern name to build core system'
    method_option :clouds, type: :array, required: true, desc: 'Cloud names to build system. First cloud is primary.'
    method_option :parameter_file, type: :string,
                                   desc: 'Load parameters from file. If this option does not specified, ' \
                                         'open interactive shell to answer parameters.'
    method_option :attribute_file, type: :string, desc: 'JSON file contain chef attributes'
    def create
      payload = {
        name: options['name'],
        domain: options['domain'],
        # patterns: patterns(options['patterns']),
        # TODO: Fix API
        pattern_id: patterns(options['patterns']),
        clouds: clouds(options['clouds'])
      }
      payload[:parameters] = File.read(options['attribute_file']) if options['attribute_file']
      if options['parameter_file']
        payload[:template_parameters] = File.read(options['parameter_file'])
      else
        payload[:template_parameters] = input_template_parameters(options['patterns'])
      end
      response = connection.post('/systems', payload)
      puts response.body
      error_exit("Failed to register systems. returns #{response.status}") unless response.success?
      display_message 'Create acceppted. Building pre-build images to registered clouds.'
      display_details(JSON.parse(response.body))
    end

    desc 'update SYSTEM_ID', 'Update system'
    method_option :name, type: :string, desc: 'System name'
    method_option :domain, type: :string, desc: 'Domain name to designate this system'
    method_option :patterns, type: :array, desc: 'Platform pattern name to build core system'
    method_option :clouds, type: :array, desc: 'Cloud names to build system. First cloud is primary.'
    method_option :parameter_file, type: :string,
                                   desc: 'Load parameters from file. If this option does not specified, ' \
                                         'open interactive shell to answer parameters.'
    method_option :attribute_file, type: :string, desc: 'JSON file contain chef attributes'
    def update(id)
      payload = {}
      payload[:name] = options['name'] if options['name']
      payload[:domain] = options['domain'] if options['domain']
      payload[:patterns] = patterns(options['patterns']) if options['patterns']
      payload[:clouds] = clouds(options['clouds']) if options['clouds']
      payload[:parameters] = File.read(options['attribute_file']) if options['attribute_file']
      if options['parameter_file']
        payload[:template_parameters] = File.read(options['parameter_file'])
      else
        payload[:template_parameters] = input_parameters(options['patterns'])
      end
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

    private

    def patterns(pattern_names)
      response = connection.get('/patterns')
      patterns = JSON.parse(response.body)
      pattern_names.map do |pattern_name|
        pattern = patterns.find { |p| p['name'] == pattern_name }
        error_exit("Pattern '#{pattern_name}' does not exist") if pattern.nil?
        pattern['id']
        # TODO: Fix API
        # end
      end.first
    end

    def clouds(cloud_names)
      response = connection.get('/clouds')
      clouds = JSON.parse(response.body)
      cloud_names.map do |cloud_name|
        cloud = clouds.find { |c| c['name'] == cloud_name }
        error_exit("Cloud '#{cloud_name}' does not exist") if cloud.nil?
        {
          id: cloud['id'],
          priority: (cloud_names.size - cloud_names.index(cloud_name)) * 10
        }
      end
    end
  end
end
