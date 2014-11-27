require 'thor'

module CloudConductorCli
  module Models
    class Cloud < Thor
      include Models::Base

      desc 'list', 'List clouds'
      def list
        response = connection.get('/clouds')
        error_exit('Failed to get clouds', response) unless response.success?
        display_list(JSON.parse(response.body))
      end

      desc 'show CLOUD_NAME', 'Show cloud details'
      def show(cloud_name)
        id = find_id_by_name(:cloud, cloud_name)
        error_exit('Specified record does not exist.') unless id
        response = connection.get("/clouds/#{id}")
        error_exit("Failed to get cloud information. returns #{response.status}", response) unless response.success?
        display_details(JSON.parse(response.body))
      end

      desc 'create', 'Register cloud information'
      method_option :name,          type: :string, required: true, desc: 'User specified cloud name'
      method_option :type,          type: :string, required: true, desc: 'Type of cloud', enum: %w(aws openstack)
      method_option :entry_point,   type: :string, required: true,
                                    desc: 'AWS Region name (e.g. us-east-1) or OpenStack Keystone endpoint url'
      method_option :key,           type: :string, required: true, desc: 'AWS AccessKeyId or OpenStack user name'
      method_option :secret,        type: :string, required: true, desc: 'AWS SecretAccessKey or OpenStack user passowrd'
      method_option :tenant_name,   type: :string, desc: '(OpenStack) OpenStack tenant name'
      method_option :base_image_id, type: :string, desc: '(OpenStack) Base image id'
      def create
        payload_keys = %w(name type entry_point key secret tenant_name)
        payload = options.select { |k, _v| payload_keys.include?(k) }
        payload['targets'] = targets(options)
        response = connection.post('/clouds', payload)
        error_exit("Failed to register cloud. returns #{response.status}", response) unless response.success?
        display_message 'Register completed successfully.'
        display_details(JSON.parse(response.body))
      end

      desc 'update CLOUD_NAME', 'Update cloud information'
      method_option :name,        type: :string, desc: 'User specified cloud name'
      method_option :entry_point, type: :string, desc: 'AWS Region name (e.g. us-east-1) or OpenStack Keystone endpoint url'
      method_option :key,         type: :string, desc: 'AWS AccessKeyId or OpenStack user name'
      method_option :secret,      type: :string, desc: 'AWS SecretAccessKey or OpenStack user passowrd'
      method_option :tenant_name, type: :string, desc: '(OpenStack) OpenStack tenant name'
      def update(cloud_name)
        id = find_id_by_name(:cloud, cloud_name)
        error_exit('Specified record does not exist.') unless id
        payload_keys = %w(name entry_point key secret tenant_name)
        payload = options.select { |k, _v| payload_keys.include?(k) }
        response = connection.put("/clouds/#{id}", payload)
        error_exit("Failed to update cloud. returns #{response.status}", response) unless response.success?
        display_message 'Update completed successfully.'
        display_details(JSON.parse(response.body))
      end

      desc 'delete CLOUD_NAME', 'Delete cloud'
      def delete(cloud_name)
        id = find_id_by_name(:cloud, cloud_name)
        error_exit('Specified record does not exist.') unless id
        response = connection.delete("/clouds/#{id}")
        error_exit('Failed to delete cloud record.', response) unless response.success?
        display_message 'Delete completed successfully.'
      end
    end
  end
end
