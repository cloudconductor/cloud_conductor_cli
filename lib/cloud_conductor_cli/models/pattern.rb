require 'thor'

module CloudConductorCli
  module Models
    class Pattern < Thor
      include Models::Base

      desc 'list', 'List patterns'
      method_option :project, type: :string, desc: 'Project name or id'
      def list
        project_id = find_id_by(:project, :name, options[:project]) if options[:project]
        payload = declared(options, self.class, :list).except('project')
                  .merge('project_id' => project_id)
        response = connection.get('/patterns', payload)
        output(response)
      end

      desc 'show PATTERN', 'Show pattern details'
      method_option :project, type: :string, desc: 'Project name or id'
      def show(pattern)
        project_id = find_id_by(:project, :name, options[:project]) if options[:project]
        id = find_id_by(:pattern, :name, pattern, project_id: project_id)
        response = connection.get("/patterns/#{id}")
        output(response)
      end

      desc 'create', 'Create pattern'
      method_option :project, type: :string, required: true, desc: 'Project name or id'
      method_option :url, type: :string, required: true, desc: 'Pattern URL'
      method_option :revision, type: :string, desc: 'Repository revision'
      def create
        project_id = find_id_by(:project, :name, options[:project])
        payload = declared(options, self.class, :create).except('project').merge('project_id' => project_id)
        response = connection.post('/patterns', payload)

        message('Create completed successfully.')
        output(response)
      end

      desc 'update PATTERN', 'Update pattern information'
      method_option :url, type: :string, desc: 'Pattern URL'
      method_option :revision, type: :string, desc: 'Repository revision'
      method_option :project, type: :string, desc: 'Project name or id'
      def update(pattern)
        project_id = find_id_by(:project, :name, options[:project]) if options[:project]
        id = find_id_by(:pattern, :name, pattern, project_id: project_id)
        payload = declared(options, self.class, :update).except('project')
        response = connection.put("/patterns/#{id}", payload)

        message('Update completed successfully.')
        output(response)
      end

      desc 'delete PATTERN', 'Delete pattern'
      method_option :project, type: :string, desc: 'Project name or id'
      def delete(pattern)
        project_id = find_id_by(:project, :name, options[:project]) if options[:project]
        id = find_id_by(:pattern, :name, pattern, project_id: project_id)
        connection.delete("/patterns/#{id}")

        message('Delete completed successfully.')
      end
    end
  end
end
