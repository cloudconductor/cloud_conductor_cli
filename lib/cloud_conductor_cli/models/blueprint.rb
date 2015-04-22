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
      method_option :patterns_json, type: :string, required: true,
                                    desc: 'JSON string include pattern urls and revisions to use system construction.',
                                    long_desc: 'e.g. \'{[{"url": "https://github.com/cloudconductor-patterns/rails_pattern.git", "revision": "master"}]}\''
      def create
        project_id = find_id_by(:project, :name, options[:project])
        payload = declared(options, self.class, :create).except('project', 'patterns_json').merge('project_id' => project_id)
        if options['patterns_json']
          patterns_attributes = JSON.parse(options['patterns_json'])
          patterns_attributes = [patterns_attributes] unless patterns_attributes.is_a?(Array)
          payload.merge!('patterns_attributes' => patterns_attributes)
        end
        response = connection.post('/blueprints', payload)
        display_message 'Create completed successfully.'
        output(response)
      end

      desc 'update BLUEPRINT', 'Update blueprint'
      method_option :name,          type: :string, desc: 'Blueprint name'
      method_option :description,   type: :string, desc: 'Blueprint description'
      method_option :patterns_json, type: :string,
                                    desc: 'JSON string include pattern urls and revisions to use system construction.',
                                    long_desc: 'e.g. \'{[{"url": "https://github.com/cloudconductor-patterns/rails_pattern.git", "revision": "master"}]}\''
      def update(blueprint)
        id = find_id_by(:blueprint, :name, blueprint)
        payload = declared(options, self.class, :update).except('patterns_json')
        if options['patterns_json']
          patterns_attributes = JSON.parse(options['patterns_json'])
          payload.merge!('patterns_attributes' => patterns_attributes)
        end
        response = connection.put("/blueprints/#{id}", payload)
        display_message 'Update completed successfully.'
        output(response)
      end

      desc 'delete BLUEPRINT', 'Delete blueprint'
      def delete(blueprint)
        id = find_id_by(:blueprint, :name, blueprint)
        connection.delete("/blueprints/#{id}")
        display_message 'Delete completed successfully.'
      end
    end
  end
end
