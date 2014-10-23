require 'thor'

module CloudConductorCli
  module Models
    class Pattern < Thor
      include Models::Base

      desc 'list', 'List patterns'
      def list
        response = connection.get('/patterns')
        error_exit('Failed to get patterns') unless response.success?
        display_list(JSON.parse(response.body))
      end

      desc 'show PATTERN_NAME', 'Show pattern details'
      def show(pattern_name)
        id = find_id_by_name(:pattern, pattern_name)
        response = connection.get("/patterns/#{id}")
        error_exit('Specified record does not exist.') if response.status == 404
        error_exit("Failed to get pattern information. returns #{response.status}") unless response.success?
        display_details(JSON.parse(response.body))
      end

      desc 'show-parameters PATTERN_NAME', "Show pattern's template parameters"
      def show_parameters(pattern_name)
        id = find_id_by_name(:pattern, pattern_name)
        response = connection.get("/patterns/#{id}/parameters")
        error_exit('Specified record does not exist.') if response.status == 404
        error_exit("Failed to get pattern information. returns #{response.status}") unless response.success?
        display_details(JSON.parse(response.body))
      end

      desc 'create', 'Register pattern and build pre-build images'
      method_option :url,         type: :string, required: true, desc: "Pattern's git repository url"
      method_option :revision,    type: :string, default: 'master', desc: "Pattern's git repository revision"
      def create
        payload = { url: options['url'], revision: options['revision'] }
        response = connection.post('/patterns', payload)
        error_exit("Failed to register patterns. returns #{response.status}") unless response.success?
        display_message 'Create accepted. Building pre-build images to registered clouds.'
        display_details(JSON.parse(response.body))
      end

      desc 'update PATTERN_NAME', 'Update pattern and rebuild pre-build images'
      method_option :url,         type: :string, desc: "Pattern's git repository url"
      method_option :revision,    type: :string, desc: "Pattern's git repository revision"
      def update(pattern_name)
        id = find_id_by_name(:pattern, pattern_name)
        payload = { url: options['url'], revision: options['revision'] }
        response = connection.put("/patterns/#{id}", payload)
        error_exit("Failed to update pattern. returns #{response.status}") unless response.success?
        display_message 'Update completed successfully.'
        display_details(JSON.parse(response.body))
      end

      desc 'delete PATTERN_NAME', 'Delete pattern'
      def delete(pattern_name)
        id = find_id_by_name(:pattern, pattern_name)
        response = connection.delete("/patterns/#{id}")
        error_exit('Specified pattern record does not exist.') if response.status == 404
        error_exit('Failed to delete pattern record.') unless response.success?
        display_message 'Delete completed successfully.'
      end
    end
  end
end
