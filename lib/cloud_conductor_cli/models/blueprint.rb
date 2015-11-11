require 'thor'

module CloudConductorCli
  module Models
    class Blueprint < Thor
      include Models::Base

      desc 'list', 'List blueprints'
      def list
        response = connection.get('/blueprints')
        output(response)
      end

      desc 'show BLUEPRINT', 'Show blueprint details'
      def show(blueprint)
        id = find_id_by(:blueprint, :name, blueprint)
        response = connection.get("/blueprints/#{id}")
        output(response)
      end

      desc 'create', 'Create new blueprint'
      method_option :project, type: :string, required: true, desc: 'Project name or id'
      method_option :name, type: :string, required: true, desc: 'Blueprint name'
      method_option :description, type: :string, desc: 'Blueprint description'
      def create
        project_id = find_id_by(:project, :name, options[:project])
        payload = declared(options, self.class, :create).except('project').merge('project_id' => project_id)
        response = connection.post('/blueprints', payload)

        message('Create completed successfully.')
        output(response)
      end

      desc 'update BLUEPRINT', 'Update blueprint'
      method_option :name,          type: :string, desc: 'Blueprint name'
      method_option :description,   type: :string, desc: 'Blueprint description'
      def update(blueprint)
        id = find_id_by(:blueprint, :name, blueprint)
        payload = declared(options, self.class, :update)
        response = connection.put("/blueprints/#{id}", payload)

        message('Update completed successfully.')
        output(response)
      end

      desc 'delete BLUEPRINT', 'Delete blueprint'
      def delete(blueprint)
        id = find_id_by(:blueprint, :name, blueprint)
        connection.delete("/blueprints/#{id}")

        message('Delete completed successfully.')
      end
    end
  end
end
