require 'thor'

module CloudConductorCli
  module Models
    class System < Thor
      include Models::Base

      desc 'list', 'List systems'
      def list
        response = connection.get('/systems')
        output(response)
      end

      desc 'show SYSTEM', 'Show system details'
      def show(system)
        id = find_id_by(:system, :name, system)
        response = connection.get("/systems/#{id}")
        output(response)
      end

      desc 'create', 'Create system'
      method_option :project, type: :string, required: true, desc: 'Project name or id'
      method_option :name, type: :string, required: true, desc: 'System name'
      method_option :description, type: :string, desc: 'System description'
      method_option :domain, type: :string, desc: 'System domain name'
      def create
        project_id = find_id_by(:project, :name, options[:project])
        payload = declared(options, self.class, :create).except('project').merge('project_id' => project_id)
        response = connection.post('/systems', payload)
        display_message 'Create completed successfully.'
        output(response)
      end

      desc 'update SYSTEM', 'Update system'
      method_option :name, type: :string, desc: 'System name'
      method_option :description, type: :string, desc: 'System description'
      method_option :domain, type: :string, desc: 'System domain name'
      def update(system)
        id = find_id_by(:system, :name, system)
        payload = declared(options, self.class, :update)
        response = connection.put("/systems/#{id}", payload)
        display_message 'Update completed successfully.'
        output(response)
      end

      desc 'delete SYSTEM', 'Delete system'
      def delete(system)
        id = find_id_by(:system, :name, system)
        connection.delete("/systems/#{id}")
        display_message 'Delete completed successfully.'
      end

      desc 'switch SYSTEM', 'Switch primary environment'
      method_option :environment, type: :string, required: true, desc: 'Environment name'
      def switch(system)
        id = find_id_by(:system, :name, system)
        environment_id = find_id_by(:environment, :name, options['environment'])
        payload = declared(options, self.class, :switch).except('environment').merge('environment_id' => environment_id)
        response = connection.put("/systems/#{id}/switch", payload)
        display_message 'Switch completed successfully.'
        output(response)
      end
    end
  end
end
