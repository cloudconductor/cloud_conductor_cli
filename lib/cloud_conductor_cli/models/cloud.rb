require 'thor'

module CloudConductorCli
  module Models
    class Cloud < Thor
      include Models::Base

      desc 'list', 'List clouds'
      method_option :project, type: :string, desc: 'Project name or id'
      def list
        project_id = find_id_by(:project, :name, options[:project]) if options[:project]
        payload = declared(options, self.class, :list).except('project')
                  .merge('project_id' => project_id)
        response = connection.get('/clouds', payload)
        output(response)
      end

      desc 'show CLOUD', 'Show cloud details'
      method_option :project, type: :string, desc: 'Project name or id'
      def show(cloud)
        project_id = find_id_by(:project, :name, options[:project]) if options[:project]
        id = find_id_by(:cloud, :name, cloud, project_id: project_id)
        response = connection.get("/clouds/#{id}")
        output(response)
      end

      desc 'create', 'Create cloud'
      method_option :project, type: :string, required: true, desc: 'Project name or id'
      method_option :name, type: :string, required: true, desc: 'User specified cloud name'
      method_option :type, type: :string, required: true, desc: 'Type of cloud', enum: %w(aws openstack wakame-vdc)
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
        message('Create completed successfully.')
        output(response)
      end

      desc 'update CLOUD', 'Update cloud information'
      method_option :name, type: :string, desc: 'User specified cloud name'
      method_option :type, type: :string, desc: 'Type of cloud', enum: %w(aws openstack wakame-vdc)
      method_option :entry_point, type: :string, desc: 'AWS Region name (e.g. us-east-1) or OpenStack Keystone endpoint url'
      method_option :key, type: :string, desc: 'AWS AccessKeyId or OpenStack user name'
      method_option :secret, type: :string, desc: 'AWS SecretAccessKey or OpenStack user passowrd'
      method_option :description, type: :string, desc: 'Cloud description'
      method_option :tenant_name, type: :string, desc: '(OpenStack) OpenStack tenant name'
      method_option :project, type: :string, desc: 'Project name or id'
      def update(cloud)
        project_id = find_id_by(:project, :name, options[:project]) if options[:project]
        id = find_id_by(:cloud, :name, cloud, project_id: project_id)
        payload = declared(options, self.class, :update).except('project')
        response = connection.put("/clouds/#{id}", payload)
        message('Update completed successfully.')
        output(response)
      end

      desc 'delete CLOUD', 'Delete cloud'
      method_option :project, type: :string, desc: 'Project name or id'
      def delete(cloud)
        project_id = find_id_by(:project, :name, options[:project]) if options[:project]
        id = find_id_by(:cloud, :name, cloud, project_id: project_id)
        connection.delete("/clouds/#{id}")
        message('Delete completed successfully.')
      end
    end
  end
end
