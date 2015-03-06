require 'thor'

module CloudConductorCli
  module Models
    class System < Thor
      include Models::Base

      desc 'list', 'List systems'
      def list
        response = connection.get('/systems')
        display_list(JSON.parse(response.body))
      end

      desc 'show SYSTEM', 'Show system details'
      def show(system)
        id = find_id_by(:system, :name, system)
        response = connection.get("/systems/#{id}")
        display_details(JSON.parse(response.body))
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
        display_details(JSON.parse(response.body))
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
        display_details(JSON.parse(response.body))
      end

      desc 'delete SYSTEM', 'Delete system'
      def delete(system)
        id = find_id_by(:system, :name, system)
        connection.delete("/systems/#{id}")
        display_message 'Delete completed successfully.'
      end
    end
  end
end
