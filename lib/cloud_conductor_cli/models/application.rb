require 'thor'

module CloudConductorCli
  module Models
    class Application < Thor
      include Models::Base

      desc 'list', 'List applications'
      def list
        response = connection.get('/applications')
        output(response)
      end

      desc 'show APPLICATION', 'Show application details'
      method_option :version, type: :string, desc: 'Application version'
      def show(application)
        id = find_id_by(:application, :name, application)
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
      def create
        system_id = find_id_by(:system, :name, options['system'])
        payload = declared(options, self.class, :create).except('system').merge('system_id' => system_id)
        response = connection.post('/applications', payload)
        display_message 'Create complete successfully.'
        output(response)
      end

      desc 'update APPLICATION', 'Update application'
      method_option :name,        type: :string, desc: 'Application name'
      method_option :description, type: :string, desc: 'Application description'
      def update(application)
        id = find_id_by(:application, :name, application)
        payload = declared(options, self.class, :update)
        response = connection.put("/applications/#{id}", payload)
        display_message 'Update completed successfully.'
        output(response)
      end

      desc 'delete APPLICATION', 'Delete application'
      def delete(application)
        id = find_id_by(:application, :name, application)
        connection.delete("/applications/#{id}")
        display_message 'Delete completed successfully.'
      end

      desc 'release APPLICATION', 'Release new application version'
      method_option :url, type: :string, required: true, desc: 'Application git repository or tar ball url'
      method_option :revision, type: :string, desc: 'Application git repository revision', default: 'master'
      method_option :protocol, type: :string, desc: 'Application url type (git or http)', default: 'git'
      method_option :type, type: :string, desc: 'Application type', enum: %w(static, dynamic), default: 'dynamic'
      method_option :pre_deploy, type: :string, desc: 'Pre deploy script'
      method_option :post_deploy, type: :string, desc: 'Post deploy script'
      method_option :parameters, type: :string, desc: 'Application parameters'
      def release(application)
        application_id = find_id_by(:application, :name, application)
        payload = declared(options, self.class, :release)
        response = connection.post("/applications/#{application_id}/histories", payload)
        display_message 'Create complete successfully.'
        output(response)
      end

      # desc 'delete-version APPLICATION VERSION', 'Delete application version'
      # def delete_version(application, version)
      #   application_id = find_id_by(:application, :name, application)
      #   history_id = find_id_by(:application_history, :version, version)
      #   connection.delete("/applications/#{application_id}/histories/#{history_id}")
      #   display_message 'Delete completed successfully.'
      # end

      desc 'deploy APPLICATION', 'Deploy application to specified environment'
      method_option :version, type: :string, desc: 'Application version (use latest version if unspecified)'
      method_option :environment, type: :string, required: true, desc: 'Target environment name or id'
      # TODO: Fix API
      # method_option :domain, type: :string, desc: 'Application domain'
      def deploy(application)
        application_id = find_id_by(:application, :name, application)
        environment_id = find_id_by(:environment, :name, options['environment'])
        payload = { 'environment_id' => environment_id }
        if options['version']
          application_history_id = find_id_by(:history, :version, options['version'], parent_model: :application, parent_id: application_id)
          payload.merge!('application_history_id' => application_history_id)
        end
        response = connection.post("/applications/#{application_id}/deploy", payload)
        display_message 'Accepted successfully. Deploying application to environment.'
        output(response)
      end
    end
  end
end
