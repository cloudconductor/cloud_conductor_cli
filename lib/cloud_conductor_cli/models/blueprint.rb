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

      desc 'build', 'Build blueprint and images'
      def build(blueprint)
        id = find_id_by(:blueprint, :name, blueprint)
        response = connection.post("/blueprints/#{id}/build")

        message('Building blueprint has been accepted.')
        output(response)
      end

      desc 'pattern-list', 'List patterns are contained in blueprint'
      def pattern_list(blueprint)
        id = find_id_by(:blueprint, :name, blueprint)
        response = connection.get("/blueprints/#{id}/patterns")
        output(response)
      end

      desc 'pattern-add', 'Add pattern to blueprint'
      method_option :pattern, type: :string, required: true, desc: 'Pattern name or id'
      method_option :revision, type: :string, desc: 'Pattern revision'
      method_option :os_version, type: :string, desc: 'OS version'
      def pattern_add(blueprint)
        id = find_id_by(:blueprint, :name, blueprint)
        pattern_id = find_id_by(:pattern, :name, options[:pattern])
        payload = declared(options, self.class, :pattern_add).except('pattern').merge('pattern_id' => pattern_id)
        response = connection.post("/blueprints/#{id}/patterns", payload)

        message('Add pattern completed successfully.')
        output(response)
      end

      desc 'pattern-update', 'Update pattern on blueprint'
      method_option :pattern, type: :string, required: true, desc: 'Pattern name or id'
      method_option :revision, type: :string, desc: 'Pattern revision'
      method_option :os_version, type: :string, desc: 'OS version'
      def pattern_update(blueprint)
        id = find_id_by(:blueprint, :name, blueprint)
        pattern_id = find_id_by(:pattern, :name, options[:pattern])
        payload = declared(options, self.class, :pattern_update).except('pattern')
        response = connection.put("/blueprints/#{id}/patterns/#{pattern_id}", payload)

        message('Update pattern completed successfully.')
        output(response)
      end

      desc 'pattern-delete', 'Delete pattern from blueprint'
      method_option :pattern, type: :string, required: true, desc: 'Pattern name or id'
      def pattern_delete(blueprint)
        id = find_id_by(:blueprint, :name, blueprint)
        pattern_id = find_id_by(:pattern, :name, options[:pattern])
        response = connection.delete("/blueprints/#{id}/patterns/#{pattern_id}")

        message('Delete pattern completed successfully.')
        output(response)
      end
    end
  end
end
