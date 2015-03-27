require 'thor'

module CloudConductorCli
  module Models
    class Cloud < Thor
      include Models::Base

      desc 'list', 'List clouds'
      def list
        response = connection.get('/clouds')
        display_list(JSON.parse(response.body))
      end

      desc 'show CLOUD', 'Show cloud details'
      def show(cloud)
        id = find_id_by(:cloud, :name, cloud)
        response = connection.get("/clouds/#{id}")
        display_details(JSON.parse(response.body))
      end

      desc 'create', 'Create cloud'
      method_option :project, type: :string, required: true, desc: 'Project name or id'
      method_option :name, type: :string, required: true, desc: 'User specified cloud name'
      method_option :type, type: :string, required: true, desc: 'Type of cloud', enum: %w(aws openstack)
      method_option :entry_point, type: :string, required: true,
                                  desc: 'AWS Region name (e.g. us-east-1) or OpenStack Keystone endpoint url'
      method_option :key, type: :string, required: true, desc: 'AWS AccessKeyId or OpenStack user name'
      method_option :secret, type: :string, required: true, desc: 'AWS SecretAccessKey or OpenStack user passowrd'
      method_option :description, type: :string, desc: 'Cloud description'
      method_option :tenant_name, type: :string, desc: '(OpenStack) OpenStack tenant name'
      def create
        project_id = find_id_by(:project, :name, options[:project])
        payload = declared(options, self.class, :create).except('project').merge('project_id' => project_id)
        response = connection.post('/clouds', payload)
        display_message 'Create completed successfully.'
        display_details(JSON.parse(response.body))
      end

      desc 'update CLOUD', 'Update cloud information'
      method_option :name, type: :string, desc: 'User specified cloud name'
      method_option :type, type: :string, desc: 'Type of cloud', enum: %w(aws openstack)
      method_option :entry_point, type: :string, desc: 'AWS Region name (e.g. us-east-1) or OpenStack Keystone endpoint url'
      method_option :key, type: :string, desc: 'AWS AccessKeyId or OpenStack user name'
      method_option :secret, type: :string, desc: 'AWS SecretAccessKey or OpenStack user passowrd'
      method_option :description, type: :string, desc: 'Cloud description'
      method_option :tenant_name, type: :string, desc: '(OpenStack) OpenStack tenant name'
      def update(cloud)
        id = find_id_by(:cloud, :name, cloud)
        payload = declared(options, self.class, :update)
        response = connection.put("/clouds/#{id}", payload)
        display_message 'Update completed successfully.'
        display_details(JSON.parse(response.body))
      end

      desc 'delete CLOUD', 'Delete cloud'
      def delete(cloud)
        id = find_id_by(:cloud, :name, cloud)
        connection.delete("/clouds/#{id}")
        display_message 'Delete completed successfully.'
      end
    end
  end
end
