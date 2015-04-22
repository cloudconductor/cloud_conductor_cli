require 'thor'

module CloudConductorCli
  module Models
    class BaseImage < Thor
      include Models::Base

      desc 'list', 'List base_images'
      def list
        response = connection.get('/base_images')
        output(response)
      end

      desc 'show BASE_IMAGE', 'Show base_image details'
      def show(base_image)
        id = find_id_by(:base_image, :source_image, base_image)
        response = connection.get("/base_images/#{id}")
        output(response)
      end

      desc 'create', 'Create base_image'
      method_option :cloud, type: :string, required: true, desc: 'Cloud name or id'
      method_option :source_image, type: :string, required: true, desc: 'Base image id'
      method_option :ssh_username, type: :string, desc: 'SSH login username', default: 'ec2-user'
      # method_option :os, type: :string, desc: 'OS name', default: 'CentOS-6.5'
      def create
        cloud_id = find_id_by(:cloud, :name, options[:cloud])
        payload = declared(options, self.class, :create).except('cloud').merge('cloud_id' => cloud_id, 'os' => 'CentOS-6.5')
        response = connection.post('/base_images', payload)

        display_message 'Create completed successfully.'
        output(response)
      end

      desc 'update BASE_IMAGE', 'Update base_image information'
      method_option :source_image, type: :string, required: true, desc: 'Base image id'
      method_option :ssh_username, type: :string, desc: 'SSH login username', default: 'ec2-user'
      def update(base_image)
        id = find_id_by(:base_image, :source_image, base_image)
        payload = declared(options, self.class, :update)
        response = connection.put("/base_images/#{id}", payload)

        display_message 'Update completed successfully.'
        output(response)
      end

      desc 'delete BASE_IMAGE', 'Delete base_image'
      def delete(base_image)
        id = find_id_by(:base_image, :source_image, base_image)
        connection.delete("/base_images/#{id}")

        display_message 'Delete completed successfully.'
      end
    end
  end
end
