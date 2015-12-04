require 'thor'

module CloudConductorCli
  module Models
    class System < Thor
      include Models::Base

      desc 'list', 'List systems'
      method_option :project, type: :string, desc: 'Project name or id'
      def list
        project_id = find_id_by(:project, :name, options[:project]) if options[:project]
        payload = { 'project_id' => project_id }
        response = connection.get('/systems', payload)
        output(response)
      end

      desc 'show SYSTEM', 'Show system details'
      method_option :project, type: :string, desc: 'Project name or id'
      def show(system)
        project_id = find_id_by(:project, :name, options[:project]) if options[:project]
        id = find_id_by(:system, :name, system, project_id: project_id)
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
        message('Create completed successfully.')
        output(response)
      end

      desc 'update SYSTEM', 'Update system'
      method_option :name, type: :string, desc: 'System name'
      method_option :description, type: :string, desc: 'System description'
      method_option :domain, type: :string, desc: 'System domain name'
      method_option :project, type: :string, desc: 'Project name or id'
      def update(system)
        project_id = find_id_by(:project, :name, options[:project]) if options[:project]
        id = find_id_by(:system, :name, system, project_id: project_id)
        payload = declared(options, self.class, :update).except('project')
        response = connection.put("/systems/#{id}", payload)
        message('Update completed successfully.')
        output(response)
      end

      desc 'delete SYSTEM', 'Delete system'
      method_option :project, type: :string, desc: 'Project name or id'
      def delete(system)
        project_id = find_id_by(:project, :name, options[:project]) if options[:project]
        id = find_id_by(:system, :name, system, project_id: project_id)
        connection.delete("/systems/#{id}")
        message('Delete completed successfully.')
      end

      desc 'switch SYSTEM', 'Switch primary environment'
      method_option :environment, type: :string, required: true, desc: 'Environment name'
      method_option :project, type: :string, desc: 'Project name or id'
      def switch(system)
        project_id = find_id_by(:project, :name, options[:project]) if options[:project]
        id = find_id_by(:system, :name, system, project_id: project_id)
        environment_id = find_id_by(:environment, :name, options['environment'])
        payload = declared(options, self.class, :switch).except('environment', 'project').merge('environment_id' => environment_id)
        response = connection.put("/systems/#{id}/switch", payload)
        message('Switch completed successfully.')
        output(response)
      end
    end
  end
end
