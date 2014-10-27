require 'thor'

module CloudConductorCli
  module Models
    class Application < Thor
      include Models::Base

      desc 'list', 'List applications'
      method_option :system_name, type: :string, required: true, desc: 'Target system name'
      def list
        system_id = find_id_by_name(:system, options['system_name'])
        error_exit('Specified record does not exist.') unless system_id
        response = connection.get("/systems/#{system_id}/applications")
        error_exit('Failed to get applications', response) unless response.success?
        display_list(JSON.parse(response.body))
      end

      desc 'show APPLICATION_NAME', 'Show application details'
      method_option :system_name, type: :string, required: true, desc: 'Target system name'
      def show(application_name)
        system_id = find_id_by_name(:system, options['system_name'])
        error_exit('Specified record does not exist.') unless system_id
        id = find_id_by_name(:application, application_name, parent_model: :system, parent_id: system_id)
        error_exit('Specified record does not exist.') unless id
        response = connection.get("/systems/#{system_id}/applications/#{id}")
        error_exit("Failed to get application information. returns #{response.status}", response) unless response.success?
        display_details(JSON.parse(response.body))
      end

      desc 'create', 'Register and deploy application'
      method_option :system_name, type: :string, required: true, desc: 'Target system name'
      method_option :name,        type: :string, required: true, desc: 'Application name'
      method_option :domain,      type: :string, required: true, desc: 'Domain name to point this application'
      method_option :type,        type: :string, default: 'dynamic', desc: 'Application type (dynamic or static)', enum: %w(dynamic static)
      method_option :protocol,    type: :string, default: 'git', desc: 'Application file transferred protocol', enum: %w(git http)
      method_option :url,         type: :string, required: true, desc: "Application's git repository or tar.gz url"
      method_option :revision,    type: :string, default: 'master', desc: "Application's git repository revision"
      method_option :pre_deploy,  type: :string, desc: 'Shellscript to run before deploy'
      method_option :post_deploy, type: :string, desc: 'Shellscript to run after deploy'
      method_option :parameters,  type: :string, desc: 'JSON string to apply additional configuration'
      def create
        system_id = find_id_by_name(:system, options['system_name'])
        error_exit('Specified record does not exist.') unless system_id
        payload_keys = %w(name domain type protocol url revision pre_deploy post_deploy parameters)
        payload = options.select { |k, _v| payload_keys.include?(k) }
        response = connection.post("/systems/#{system_id}/applications", payload)
        error_exit("Failed to register applications. returns #{response.status}", response) unless response.success?
        display_message 'Create accepted. Deploying application.'
        display_details(JSON.parse(response.body))
      end

      desc 'update APPLICATION_NAME', 'Update and re-deploy application'
      method_option :system_name, type: :string, required: true, desc: 'Target system name'
      method_option :name,        type: :string, desc: 'Application name'
      method_option :domain,      type: :string, desc: 'Domain name to point this application'
      method_option :type,        type: :string, desc: 'Application type (dynamic or static)', enum: %w(dynamic static)
      method_option :protocol,    type: :string, desc: 'Application file transferred protocol', enum: %w(git http)
      method_option :url,         type: :string, desc: "Application's git repository or tar.gz url"
      method_option :revision,    type: :string, desc: "Application's git repository revision"
      method_option :pre_deploy,  type: :string, desc: 'Shellscript to run before deploy'
      method_option :post_deploy, type: :string, desc: 'Shellscript to run after deploy'
      method_option :parameters,  type: :string, desc: 'JSON string to apply additional configuration'
      def update(application_name)
        system_id = find_id_by_name(:system, options['system_name'])
        error_exit('Specified record does not exist.') unless system_id
        id = find_id_by_name(:application, application_name, parent_model: :system, parent_id: system_id)
        error_exit('Specified record does not exist.') unless id
        payload_keys = %w(name domain type protocol url revision pre_deploy post_deploy parameters)
        payload = options.select { |k, _v| payload_keys.include?(k) }
        response = connection.put("/systems/#{system_id}/applications/#{id}", payload)
        error_exit("Failed to update application. returns #{response.status}", response) unless response.success?
        display_message 'Update completed successfully.'
        display_details(JSON.parse(response.body))
      end

      desc 'delete APPLICATION_ID', 'Delete application'
      method_option :system_name, type: :string, required: true, desc: 'Target system name'
      def delete(application_name)
        system_id = find_id_by_name(:system, options['system_name'])
        error_exit('Specified record does not exist.') unless system_id
        id = find_id_by_name(:application, application_name, parent_model: :system, parent_id: system_id)
        error_exit('Specified record does not exist.') unless id
        response = connection.delete("/systems/#{system_id}/applications/#{id}")
        error_exit('Failed to delete application record.', response) unless response.success?
        display_message 'Delete completed successfully.'
      end
    end
  end
end
