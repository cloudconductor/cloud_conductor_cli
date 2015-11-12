require 'json'
require 'active_support/inflector'

module CloudConductorCli
  module Helpers
    module Record
      def connection
        @connection || @connection = Connection.new(options[:host], options[:port])
      end

      def declared(options, klass, command)
        declared_options = klass.commands[command.to_s].options.keys
        options.select { |key, _value| declared_options.include?(key.to_sym) }
      end

      def list_records(model, parent_model: nil, parent_id: nil)
        if parent_model
          request_path = "/#{parent_model.to_s.pluralize}/#{parent_id}/#{model.to_s.pluralize}"
        else
          request_path = "/#{model.to_s.pluralize}"
        end
        response = connection.get(request_path)
        JSON.parse(response.body)
      end

      def where(model, conditions, parent_model: nil, parent_id: nil)
        records = list_records(model, parent_model: parent_model, parent_id: parent_id)
        records.select do |record|
          conditions.all? do |key, value|
            record[key.to_s] == value
          end
        end
      end

      def find_by(model, conditions, parent_model: nil, parent_id: nil)
        where(model, conditions, parent_model: parent_model, parent_id: parent_id).first
      end

      def find_id_by(model, key, value, parent_model: nil, parent_id: nil)
        record = find_by(model, Hash[key, value], parent_model: parent_model, parent_id: parent_id)
        record ||= find_by(model, id: value.to_i, parent_model: parent_model, parent_id: parent_id)
        if record
          record['id']
        else
          error_exit("#{model.to_s.capitalize} '#{value}' does not exist.")
        end
      end

      def template_parameters(blueprint_name, version)
        blueprint_id = find_id_by(:blueprint, :name, blueprint_name)
        response = connection.get("/blueprints/#{blueprint_id}/histories/#{version}/parameters")
        JSON.parse(response.body)
      end

      def default_parameters(blueprint_name, version)
        defaults = template_parameters(blueprint_name, version)
        defaults.each do |_, parameters|
          parameters.each do |key, value|
            parameters[key] = value['Default']
          end
        end
      end

      def build_template_parameters(environment, options)
        if options['blueprint']
          blueprint_name = options['blueprint']
          version = options['version']
        elsif environment
          environment_id = find_id_by(:environment, :name, environment)
          environment = find_by(:environment, id: environment_id)
          blueprint_history = find_by(:history, id: environment['blueprint_history_id'], parent_model: :blueprint)
          blueprint_name = blueprint_history ? blueprint_history['blueprint_id'] : nil
          version = blueprint_history ? blueprint_history['version'] : nil
        end

        if options['parameter_file']
          defaults = default_parameters(blueprint_name, version)
          input_parameters = defaults.deep_merge(JSON.parse(File.read(options['parameter_file'])))
        else
          input_parameters = blueprint_name ? input_template_parameters(blueprint_name, version) : {}
        end
        JSON.dump(input_parameters || {})
      end

      def build_user_attributes(options)
        if options['user_attribute_file']
          user_attributes = JSON.parse(File.read(options['user_attribute_file']))
        else
          user_attributes = {}
        end
        JSON.dump(user_attributes)
      end
    end
  end
end
