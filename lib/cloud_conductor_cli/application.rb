require 'thor'

module CloudConductorCli
  class Application < Thor
    include Base

    desc 'list', 'List applications'
    method_option :system_id, type: :string, required: true, desc: 'System id'
    def list
      response = connection.get("/systems/#{options['system_id']}/applications")
      error_exit('Failed to get applications') unless response.success?
      display_list(JSON.parse(response.body))
    end

    desc 'show APPLICATION_ID', 'Show application details'
    method_option :system_id, type: :string, required: true, desc: 'System id'
    def show(id)
      response = connection.get("/systems/#{options['system_id']}/applications/#{id}")
      error_exit('Specified record does not exist.') if response.status == 404
      error_exit("Failed to get application information. returns #{response.status}") unless response.success?
      display_details(JSON.parse(response.body))
    end

    desc 'create', 'Register and deploy application'
    method_option :system_id,   type: :string, required: true, desc: 'System id'
    method_option :name,        type: :string, required: true, desc: 'Application name'
    method_option :domain,      type: :string, required: true, desc: 'Domain name to point this application'
    method_option :type,        type: :string, default: 'ruby', desc: 'Application type (ruby or static)', enum: %w(ruby static)
    method_option :protocol,    type: :string, default: 'git', desc: 'Application file transferred protocol', enum: %w(git http)
    method_option :url,         type: :string, required: true, desc: "Application's git repository or tar.gz url"
    method_option :revision,    type: :string, default: 'master', desc: "Application's git repository revision"
    method_option :pre_deploy,  type: :string, desc: 'Shellscript to run before deploy'
    method_option :post_deploy, type: :string, desc: 'Shellscript to run after deploy'
    method_option :parameters,  type: :string, desc: 'JSON string to apply additional configuration'
    def create
      payload_keys = %w(name domain type protocol url revision pre_deploy post_deploy parameters)
      payload = options.select { |k, _v| payload_keys.include?(k) }
      response = connection.post("/systems/#{options['system_id']}/applications", payload)
      puts response.body
      error_exit("Failed to register applications. returns #{response.status}") unless response.success?
      display_message 'Create acceppted. Deploying application.'
      display_details(JSON.parse(response.body))
    end

    desc 'update APPLICATION_ID', 'Update and re-deploy application'
    method_option :system_id,   type: :string, required: true, desc: 'System id'
    method_option :name,        type: :string, desc: 'Application name'
    method_option :type,        type: :string, desc: 'Application type (ruby or static)', enum: %w(ruby static)
    method_option :protocol,    type: :string, desc: 'Application file transferred protocol', enum: %w(git http)
    method_option :url,         type: :string, desc: "Application's git repository or tar.gz url"
    method_option :revision,    type: :string, desc: "Application's git repository revision"
    method_option :pre_deploy,  type: :string, desc: 'Shellscript to run before deploy'
    method_option :post_deploy, type: :string, desc: 'Shellscript to run after deploy'
    method_option :parameters,  type: :string, desc: 'JSON string to apply additional configuration'
    def update(id)
      payload_keys = %w(name type protocol url revision pre_deploy post_deploy parameters)
      payload = options.select { |k, _v| payload_keys.include?(k) }
      response = connection.put("/systems/#{options['system_id']}/applications/#{id}", payload)
      error_exit("Failed to update application. returns #{response.status}") unless response.success?
      display_message 'Update completed successfully.'
      display_details(JSON.parse(response.body))
    end

    desc 'delete APPLICATION_ID', 'Delete application and pre-build images'
    method_option :system_id, type: :string, required: true, desc: 'System id'
    def delete(id)
      response = connection.delete("/systems/#{options['system_id']}/applications/#{id}")
      error_exit('Specified application record does not exist.') if response.status == 404
      error_exit('Failed to delete application record.') unless response.success?
      display_message 'Delete completed successfully.'
    end
  end
end
