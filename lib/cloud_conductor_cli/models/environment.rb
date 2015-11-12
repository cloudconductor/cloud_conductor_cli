require 'thor'

module CloudConductorCli
  module Models
    class Environment < Thor
      include Models::Base

      desc 'list', 'List environments'
      def list
        response = connection.get('/environments')
        output(response)
      end

      desc 'show ENVIRONMENT', 'Show environment details'
      def show(environment)
        id = find_id_by(:environment, :name, environment)
        response = connection.get("/environments/#{id}")
        output(response)
      end

      desc 'create', 'Create environment from blueprint'
      method_option :system, type: :string, required: true, desc: 'System name or id'
      method_option :blueprint, type: :string, required: true, desc: 'Blueprint name or id'
      method_option :version, type: :numeric, required: true, desc: 'Blueprint version'
      method_option :name, type: :string, required: true, desc: 'Environment name'
      method_option :description, type: :string, desc: 'Environment description'
      method_option :clouds, type: :array, required: true, desc: 'Cloud names to build system. ordered by priority desc.'
      method_option :parameter_file, type: :string,
                                     desc: 'Load pattern parameters from json file',
                                     long_desc: 'If this option does not specified, open interactive shell to answer parameters.'
      method_option :user_attribute_file, type: :string, desc: 'Load additional chef attributes from json file'
      def create
        system_id = find_id_by(:system, :name, options[:system])
        blueprint_id = find_id_by(:blueprint, :name, options[:blueprint])
        candidates_attributes = options['clouds'].map.with_index do |cloud, i|
          { cloud_id: find_id_by(:cloud, :name, cloud),
            priority: (options['clouds'].size - i) * 10 }
        end
        candidates_attributes.reject! { |candidates| candidates[:cloud_id].nil? }
        template_parameters = build_template_parameters(nil, options)
        user_attributes = build_user_attributes(options)
        payload = declared(options, self.class, :create)
                  .except('system', 'blueprint', 'clouds', 'parameter_file', 'user_attribute_file')
                  .merge('system_id' => system_id, 'blueprint_id' => blueprint_id,
                         'candidates_attributes' => candidates_attributes,
                         'template_parameters' => template_parameters,
                         'user_attributes' => user_attributes)
        response = connection.post('/environments', payload)
        message('Create accepted. Provisioning environment to specified cloud.')
        output(response)
      end

      desc 'update ENVIRONMENT', 'Update environment'
      method_option :name, type: :string, desc: 'Environment name'
      method_option :description, type: :string, desc: 'Environment description'
      method_option :clouds, type: :array, desc: 'Cloud names to build system. ordered by priority desc.'
      method_option :parameter_file, type: :string,
                                     desc: 'Load pattern parameters from json file.',
                                     long_desc: 'If this option does not specified, open interactive shell to answer parameters.'
      method_option :user_attribute_file, type: :string, desc: 'Load additional chef attributes from json file'
      def update(environment)
        id = find_id_by(:environment, :name, environment)
        payload = declared(options, self.class, :update)
                  .except('clouds', 'parameter_file', 'user_attribute_file')
        if options['clouds']
          candidates_attributes = options['clouds'].map.with_index do |cloud, i|
            { cloud_id: find_id_by(:cloud, :name, cloud),
              priority: (options['clouds'].size - i) * 10 }
          end
          candidates_attributes.reject! { |candidates| candidates[:cloud_id].nil? }
          payload.merge!('candidates_attributes' => candidates_attributes)
        end
        if options['parameter_file']
          template_parameters = build_template_parameters(environment, options)
          payload.merge!('template_parameters' => template_parameters)
        end
        if options['user_attribute_file']
          user_attributes = build_user_attributes(options)
          payload.merge!('user_attributes' => user_attributes)
        end
        response = connection.put("/environments/#{id}", payload)
        message('Update completed successfully.')
        output(response)
      end

      desc 'delete ENVIRONMENT', 'Delete environment'
      def delete(environment)
        id = find_id_by(:environment, :name, environment)
        connection.delete("/environments/#{id}")
        message('Delete completed successfully.')
      end

      desc 'rebuild ENVIRONMENT', 'Rebuild environment'
      method_option :blueprint, type: :string, desc: 'Blueprint name or id'
      method_option :name, type: :string, desc: 'Environment name'
      method_option :description, type: :string, desc: 'Environment description'
      method_option :switch, type: :boolean, desc: 'Switch system primary environment automatically', default: false
      def rebuild(environment)
        payload = declared(options, self.class, :rebuild)
        if options[:blueprint]
          blueprint_id = find_id_by(:blueprint, :name, options[:blueprint])
          payload = payload.except(:blueprint).merge(blueprint_id: blueprint_id)
        end
        id = find_id_by(:environment, :name, environment)
        response = connection.post("/environments/#{id}/rebuild", payload)
        message('Rebuild accepted. creating new environment.')
        output(response)
      end

      desc 'send-event ENVIRONMENT', 'Send event to environment'
      method_option :event, type: :string, required: true, desc: 'Event name'
      def send_event(environment)
        id = find_id_by(:environment, :name, environment)
        payload = declared(options, self.class, :send_event)
        response = connection.post("/environments/#{id}/events", payload)
        event_id = JSON.parse(response.body)['event_id']
        message("Event '#{options['event']}' accepted. event_id: #{event_id}")
      end

      desc 'list-event ENVIRONMENT', 'List events'
      def list_event(environment)
        id = find_id_by(:environment, :name, environment)
        response = connection.get("/environments/#{id}/events")
        output(response)
      end

      desc 'show-event ENVIRONMENT', 'Show event details'
      method_option :event_id, type: :string, required: true, desc: 'Event id'
      def show_event(environment)
        id = find_id_by(:environment, :name, environment)
        response = connection.get("/environments/#{id}/events/#{options['event_id']}")
        case options[:format]
        when 'json' then
          output(response)
        when 'table' then
          event_details = JSON.parse(response.body)
          message('Event info', indent_level: 1)
          outputter.display_detail(event_details.except('task_results'))

          message('Task results', indent_level: 1)
          task_results = (event_details['task_results'] || []).map { |result| result.except('nodes') }
          outputter.display_list(task_results)

          message('Node results', indent_level: 1)
          node_results = ((event_details['task_results'] || []).map { |result| result['nodes'] }).flatten
          outputter.display_list(node_results)
        else
          fail "Unsupported format #{options[:format]}"
        end
      end
    end
  end
end
