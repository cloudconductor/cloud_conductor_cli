require 'thor'

module CloudConductorCli
  module Models
    class BaseImage < Thor
      include Models::Base

      desc 'list', 'List base_images'
      method_option :cloud, type: :string, desc: 'Cloud name or id'
      method_option :project, type: :string, desc: 'Project name or id'
      def list
        project_id = find_id_by(:project, :name, options[:project]) if options[:project]
        cloud_id = find_id_by(:cloud, :name, options[:cloud], project_id: project_id) if options[:cloud]
        payload = declared(options, self.class, :list).except('cloud', 'project')
                  .merge('cloud_id' => cloud_id, 'project_id' => project_id)
        response = connection.get('/base_images', payload)
        output(response)
      end

      desc 'show BASE_IMAGE', 'Show base_image details'
      method_option :cloud, type: :string, desc: 'Cloud name or id'
      method_option :project, type: :string, desc: 'Project name or id'
      def show(base_image)
        project_id = find_id_by(:project, :name, options[:project]) if options[:project]
        cloud_id = find_id_by(:cloud, :name, options[:cloud], project_id: project_id) if options[:cloud]
        id = find_id_by(:base_image, :source_image, base_image, cloud_id: cloud_id, project_id: project_id)
        response = connection.get("/base_images/#{id}")
        output(response)
      end

      desc 'create', 'Create base_image'
      method_option :cloud, type: :string, required: true, desc: 'Cloud name or id'
      method_option :source_image, type: :string, required: true, desc: 'Base image id'
      method_option :ssh_username, type: :string, desc: 'SSH login username', default: 'ec2-user'
      method_option :platform, type: :string, required: true, desc: 'Platform name'
      method_option :platform_version, type: :string, desc: 'Platform version'
      method_option :project, type: :string, desc: 'Project name or id'
      def create
        project_id = find_id_by(:project, :name, options[:project]) if options[:project]
        cloud_id = find_id_by(:cloud, :name, options[:cloud], project_id: project_id)
        payload = declared(options, self.class, :create)
                  .except('cloud', 'project')
                  .merge('cloud_id' => cloud_id)
        response = connection.post('/base_images', payload)

        message('Create completed successfully.')
        output(response)
      end

      desc 'update BASE_IMAGE', 'Update base_image information'
      method_option :source_image, type: :string, desc: 'Base image id'
      method_option :ssh_username, type: :string, desc: 'SSH login username'
      method_option :cloud, type: :string, desc: 'Cloud name or id'
      method_option :platform, type: :string, desc: 'Platform name'
      method_option :platform_version, type: :string, desc: 'Platform version'
      method_option :project, type: :string, desc: 'Project name or id'
      def update(base_image)
        project_id = find_id_by(:project, :name, options[:project]) if options[:project]
        cloud_id = find_id_by(:cloud, :name, options[:cloud], project_id: project_id) if options[:cloud]
        id = find_id_by(:base_image, :source_image, base_image, cloud_id: cloud_id, project_id: project_id)
        payload = declared(options, self.class, :update).except('cloud', 'project')
        response = connection.put("/base_images/#{id}", payload)

        message('Update completed successfully.')
        output(response)
      end

      desc 'delete BASE_IMAGE', 'Delete base_image'
      method_option :cloud, type: :string, desc: 'Cloud name or id'
      method_option :project, type: :string, desc: 'Project name or id'
      def delete(base_image)
        project_id = find_id_by(:project, :name, options[:project]) if options[:project]
        cloud_id = find_id_by(:cloud, :name, options[:cloud], project_id: project_id) if options[:cloud]
        id = find_id_by(:base_image, :source_image, base_image, cloud_id: cloud_id, project_id: project_id)
        connection.delete("/base_images/#{id}")

        message('Delete completed successfully.')
      end
    end
  end
end
