require 'thor'

module CloudConductorCli
  module Models
    class Blueprint < Thor
      include Models::Base

      desc 'list', 'List blueprints'
      method_option :project, type: :string, desc: 'Project name or id'
      def list
        project_id = find_id_by(:project, :name, options[:project]) if options[:project]
        payload = declared(options, self.class, :create).except('project').merge('project_id' => project_id)
        response = connection.get('/blueprints', payload)
        output(response)
      end

      desc 'show BLUEPRINT', 'Show blueprint details'
      method_option :project, type: :string, desc: 'Project name or id'
      def show(blueprint)
        project_id = find_id_by(:project, :name, options[:project]) if options[:project]
        id = find_id_by(:blueprint, :name, blueprint, project_id: project_id)
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
      method_option :project, type: :string, desc: 'Project name or id'
      def update(blueprint)
        project_id = find_id_by(:project, :name, options[:project]) if options[:project]
        id = find_id_by(:blueprint, :name, blueprint, project_id: project_id)
        payload = declared(options, self.class, :update).except('project')
        response = connection.put("/blueprints/#{id}", payload)

        message('Update completed successfully.')
        output(response)
      end

      desc 'delete BLUEPRINT', 'Delete blueprint'
      method_option :project, type: :string, desc: 'Project name or id'
      def delete(blueprint)
        project_id = find_id_by(:project, :name, options[:project]) if options[:project]
        id = find_id_by(:blueprint, :name, blueprint, project_id: project_id)
        connection.delete("/blueprints/#{id}")

        message('Delete completed successfully.')
      end

      desc 'build', 'Build blueprint and images'
      method_option :project, type: :string, desc: 'Project name or id'
      def build(blueprint)
        project_id = find_id_by(:project, :name, options[:project]) if options[:project]
        id = find_id_by(:blueprint, :name, blueprint, project_id: project_id)
        response = connection.post("/blueprints/#{id}/build")

        message('Building blueprint has been accepted.')
        output(response)
      end

      desc 'pattern-list BLUEPRINT', 'List patterns are contained in blueprint'
      method_option :project, type: :string, desc: 'Project name or id'
      def pattern_list(blueprint)
        project_id = find_id_by(:project, :name, options[:project]) if options[:project]
        id = find_id_by(:blueprint, :name, blueprint, project_id: project_id)
        response = connection.get("/blueprints/#{id}/patterns")
        output(response)
      end

      desc 'pattern-add BLUEPRINT', 'Add pattern to blueprint'
      method_option :pattern, type: :string, required: true, desc: 'Pattern name or id'
      method_option :revision, type: :string, desc: 'Pattern revision'
      method_option :os_version, type: :string, desc: 'OS version'
      method_option :project, type: :string, desc: 'Project name or id'
      def pattern_add(blueprint)
        project_id = find_id_by(:project, :name, options[:project]) if options[:project]
        id = find_id_by(:blueprint, :name, blueprint, project_id: project_id)
        pattern_id = find_id_by(:pattern, :name, options[:pattern], project_id: project_id)
        payload = declared(options, self.class, :pattern_add).except('pattern', 'project').merge('pattern_id' => pattern_id)
        response = connection.post("/blueprints/#{id}/patterns", payload)

        message('Add pattern completed successfully.')
        output(response)
      end

      desc 'pattern-update BLUEPRINT', 'Update pattern on blueprint'
      method_option :pattern, type: :string, required: true, desc: 'Pattern name or id'
      method_option :revision, type: :string, desc: 'Pattern revision'
      method_option :os_version, type: :string, desc: 'OS version'
      method_option :project, type: :string, desc: 'Project name or id'
      def pattern_update(blueprint)
        project_id = find_id_by(:project, :name, options[:project]) if options[:project]
        id = find_id_by(:blueprint, :name, blueprint, project_id: project_id)
        pattern_id = find_id_by(:pattern, :name, options[:pattern], project_id: project_id)
        payload = declared(options, self.class, :pattern_update).except('pattern', 'project')
        response = connection.put("/blueprints/#{id}/patterns/#{pattern_id}", payload)

        message('Update pattern completed successfully.')
        output(response)
      end

      desc 'pattern-delete BLUEPRINT', 'Delete pattern from blueprint'
      method_option :pattern, type: :string, required: true, desc: 'Pattern name or id'
      method_option :project, type: :string, desc: 'Project name or id'
      def pattern_delete(blueprint)
        project_id = find_id_by(:project, :name, options[:project]) if options[:project]
        id = find_id_by(:blueprint, :name, blueprint, project_id: project_id)
        pattern_id = find_id_by(:pattern, :name, options[:pattern], project_id: project_id)
        response = connection.delete("/blueprints/#{id}/patterns/#{pattern_id}")

        message('Delete pattern completed successfully.')
        output(response)
      end

      desc 'history-list BLUEPRINT', 'List patterns'
      method_option :project, type: :string, desc: 'Project name or id'
      def history_list(blueprint)
        project_id = find_id_by(:project, :name, options[:project]) if options[:project]
        blueprint_id = find_id_by(:blueprint, :name, blueprint, project_id: project_id)
        response = connection.get("/blueprints/#{blueprint_id}/histories")
        output(response)
      end

      desc 'history-show BLUEPRINT', 'Show bluepint history details'
      method_option :version, type: :numeric, required: true, desc: 'Blueprint history version'
      method_option :project, type: :string, desc: 'Project name or id'
      def history_show(blueprint)
        project_id = find_id_by(:project, :name, options[:project]) if options[:project]
        blueprint_id = find_id_by(:blueprint, :name, blueprint, project_id: project_id)
        response = connection.get("/blueprints/#{blueprint_id}/histories/#{options[:version]}")
        case options[:format]
        when 'json' then
          output(response)
        when 'table' then
          blueprint_history = JSON.parse(response.body)
          message('Blueprint history info', indent_level: 1)
          outputter.display_detail(blueprint_history.except('pattern_snapshots'))

          message('Pattern snapshots', indent_level: 1)
          outputter.display_list(blueprint_history['pattern_snapshots'])
        else
          fail "Unsupported format #{options[:format]}"
        end
      end

      desc 'history-delete BLUEPRINT', 'Delete blueprint history'
      method_option :version, type: :numeric, required: true, desc: 'Blueprint history version'
      method_option :project, type: :string, desc: 'Project name or id'
      def history_delete(blueprint)
        project_id = find_id_by(:project, :name, options[:project]) if options[:project]
        blueprint_id = find_id_by(:blueprint, :name, blueprint, project_id: project_id)
        connection.delete("/blueprints/#{blueprint_id}/histories/#{options[:version]}")

        message('Delete completed successfully.')
      end
    end
  end
end
