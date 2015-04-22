require 'thor'

module CloudConductorCli
  module Models
    class Project < Thor
      include Models::Base

      desc 'list', 'List projects'
      def list
        response = connection.get('/projects')
        output(response)
      end

      desc 'show PROJECT', 'Show project details'
      def show(project)
        id = find_id_by(:project, :name, project)
        response = connection.get("/projects/#{id}")
        output(response)
      end

      desc 'create', 'Create new project'
      method_option :name,          type: :string, required: true, desc: 'User specified project name'
      method_option :description,   type: :string, desc: 'Project description'
      def create
        payload = declared(options, self.class, :create)
        response = connection.post('/projects', payload)
        display_message 'Create completed successfully.'
        output(response)
      end

      desc 'update PROJECT', 'Update project information'
      method_option :name,        type: :string, desc: 'User specified project name'
      method_option :description, type: :string, desc: 'Project description'
      def update(project)
        id = find_id_by(:project, :name, project)
        payload = declared(options, self.class, :update)
        response = connection.put("/projects/#{id}", payload)
        display_message 'Update completed successfully.'
        output(response)
      end

      desc 'delete PROJECT', 'Delete project'
      def delete(project)
        id = find_id_by(:project, :name, project)
        connection.delete("/projects/#{id}")
        display_message 'Delete completed successfully.'
      end
    end
  end
end
