require 'thor'

module CloudConductorCli
  class Pattern < Thor
    include Base

    desc 'list', 'List patterns'
    def list
      response = connection.get('/patterns')
      error_exit('Failed to get patterns') unless response.success?
      display_list(JSON.parse(response.body))
    end

    desc 'show PATTERN_ID', 'Show pattern details'
    def show(id)
      response = connection.get("/patterns/#{id}")
      error_exit('Specified record does not exist.') if response.status == 404
      error_exit("Failed to get pattern information. returns #{response.status}") unless response.success?
      display_details(JSON.parse(response.body))
    end

    desc 'show-parameters PATTERN_ID', "Show pattern's template parameters"
    def show_parameters(id)
      response = connection.get("/patterns/#{id}/parameters")
      error_exit('Specified record does not exist.') if response.status == 404
      error_exit("Failed to get pattern information. returns #{response.status}") unless response.success?
      display_list(JSON.parse(response.body))
    end

    desc 'create', 'Register pattern and build pre-build images'
    method_option :url,         type: :string, required: true, desc: "Pattern's git repository url"
    method_option :revision,    type: :string, default: 'master', desc: "Pattern's git repository revision"
    def create
      payload_keys = %w(url revision)
      payload = options.select { |k, _v| payload_keys.include?(k) }
      response = connection.post('/patterns', payload)
      error_exit("Failed to register patterns. returns #{response.status}") unless response.success?
      display_message 'Create acceppted. Building pre-build images to registered clouds.'
      display_details(JSON.parse(response.body))
    end

    desc 'update PATTERN_ID', 'Update pattern and rebuild pre-build images'
    method_option :url,         type: :string, desc: "Pattern's git repository url"
    method_option :revision,    type: :string, desc: "Pattern's git repository revision"
    def update(id)
      payload_keys = %w(url revision)
      payload = options.select { |k, _v| payload_keys.include?(k) }
      response = connection.put("/patterns/#{id}", payload)
      error_exit("Failed to update pattern. returns #{response.status}") unless response.success?
      display_message 'Update completed successfully.'
      display_details(JSON.parse(response.body))
    end

    desc 'delete PATTERN_ID', 'Delete pattern and pre-build images'
    def delete(id)
      response = connection.delete("/patterns/#{id}")
      error_exit('Specified pattern record does not exist.') if response.status == 404
      error_exit('Failed to delete pattern record.') unless response.success?
      display_message 'Delete completed successfully.'
    end
  end
end
