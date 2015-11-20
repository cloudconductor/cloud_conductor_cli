require 'thor'

module CloudConductorCli
  module Models
    class Application < Thor
      include Models::Base

      desc 'list', 'List applications'
      method_option :system, type: :string, desc: 'Target system name or id'
      method_option :project, type: :string, desc: 'Target project name or id'
      def list
        project_id = find_id_by(:project, :name, options[:project]) if options[:project]
        system_id = find_id_by(:system, :name, options['system'], project_id: project_id) if options['system']
        payload = { 'system_id' => system_id, 'project_id' => project_id }
        response = connection.get('/applications', payload)
        output(response)
      end

      desc 'show APPLICATION', 'Show application details'
      method_option :version, type: :string, desc: 'Application version'
      method_option :system, type: :string, desc: 'Target system name or id'
      method_option :project, type: :string, desc: 'Target project name or id'
      def show(application)
        project_id = find_id_by(:project, :name, options[:project]) if options[:project]
        system_id = find_id_by(:system, :name, options['system'], project_id: project_id) if options['system']
        id = find_id_by(:application, :name, application, system_id: system_id, project_id: project_id)
        response = connection.get("/applications/#{id}")
        output(response)
        if options[:version]
          history_id = find_id_by(:history, :version, options[:version], parent_model: :application, parent_id: id)
          response = connection.get("/applications/#{id}/histories/#{history_id}")
          output(response)
        else
          response = connection.get("/applications/#{id}/histories")
          output(response)
        end
      end

      desc 'create', 'Create new application'
      method_option :system, type: :string, required: true, desc: 'Target system name or id'
      method_option :name, type: :string, required: true, desc: 'Application name'
      method_option :description, type: :string, desc: 'Application description'
      method_option :domain, type: :string, desc: 'Application domain'
      method_option :project, type: :string, desc: 'Target project name or id'
      def create
        project_id = find_id_by(:project, :name, options[:project]) if options[:project]
        system_id = find_id_by(:system, :name, options['system'], project_id: project_id)
        payload = declared(options, self.class, :create).except('system', 'project').merge('system_id' => system_id)
        response = connection.post('/applications', payload)

        message('Create complete successfully.')
        output(response)
      end

      desc 'update APPLICATION', 'Update application'
      method_option :name,        type: :string, desc: 'Application name'
      method_option :description, type: :string, desc: 'Application description'
      method_option :domain,      type: :string, desc: 'Application domain'
      method_option :system,      type: :string, desc: 'Target system name or id'
      method_option :project, type: :string, desc: 'Target project name or id'
      def update(application)
        project_id = find_id_by(:project, :name, options[:project]) if options[:project]
        system_id = find_id_by(:system, :name, options['system'], project_id: project_id) if options['system']
        id = find_id_by(:application, :name, application, system_id: system_id, project_id: project_id)
        payload = declared(options, self.class, :update).except('system', 'project')
        response = connection.put("/applications/#{id}", payload)

        message('Update completed successfully.')
        output(response)
      end

      desc 'delete APPLICATION', 'Delete application'
      method_option :system, type: :string, desc: 'Target system name or id'
      method_option :project, type: :string, desc: 'Target project name or id'
      def delete(application)
        project_id = find_id_by(:project, :name, options[:project]) if options[:project]
        system_id = find_id_by(:system, :name, options['system'], project_id: project_id) if options['system']
        id = find_id_by(:application, :name, application, system_id: system_id, project_id: project_id)
        connection.delete("/applications/#{id}")

        message('Delete completed successfully.')
      end

      desc 'release APPLICATION', 'Release new application version'
      method_option :url, type: :string, required: true, desc: 'Application git repository or tar ball url'
      method_option :revision, type: :string, desc: 'Application git repository revision', default: 'master'
      method_option :protocol, type: :string, desc: 'Application url type (git or http)', default: 'git'
      method_option :type, type: :string, desc: 'Application type', enum: %w(static, dynamic), default: 'dynamic'
      method_option :pre_deploy, type: :string, desc: 'Pre deploy script'
      method_option :post_deploy, type: :string, desc: 'Post deploy script'
      method_option :parameters, type: :string, desc: 'Application parameters'
      method_option :system, type: :string, desc: 'Target system name or id'
      method_option :project, type: :string, desc: 'Target project name or id'
      def release(application)
        project_id = find_id_by(:project, :name, options[:project]) if options[:project]
        system_id = find_id_by(:system, :name, options['system'], project_id: project_id) if options['system']
        application_id = find_id_by(:application, :name, application, system_id: system_id, project_id: project_id)
        payload = declared(options, self.class, :release).except('system')
        response = connection.post("/applications/#{application_id}/histories", payload)

        message('Create complete successfully.')
        output(response)
      end

      # desc 'delete-version APPLICATION VERSION', 'Delete application version'
      # def delete_version(application, version)
      #   application_id = find_id_by(:application, :name, application)
      #   history_id = find_id_by(:application_history, :version, version)
      #   connection.delete("/applications/#{application_id}/histories/#{history_id}")
      #   message('Delete completed successfully.')
      # end

      desc 'deploy APPLICATION', 'Deploy application to specified environment'
      method_option :version, type: :string, desc: 'Application version (use latest version if unspecified)'
      method_option :environment, type: :string, required: true, desc: 'Target environment name or id'
      method_option :system, type: :string, desc: 'Target system name or id'
      method_option :project, type: :string, desc: 'Target project name or id'
      def deploy(application)
        project_id = find_id_by(:project, :name, options[:project]) if options[:project]
        system_id = find_id_by(:system, :name, options['system'], project_id: project_id) if options['system']
        application_id = find_id_by(:application, :name, application, system_id: system_id, project_id: project_id)
        environment_id = find_id_by(:environment, :name, options['environment'], system_id: system_id, project_id: project_id)
        payload = { 'environment_id' => environment_id }
        if options['version']
          application_history_id = find_id_by(:history, :version, options['version'], parent_model: :application, parent_id: application_id)
          payload.merge!('application_history_id' => application_history_id)
        end
        response = connection.post("/applications/#{application_id}/deploy", payload)

        message('Accepted successfully. Deploying application to environment.')
        output(response)
      end
    end
  end
end
