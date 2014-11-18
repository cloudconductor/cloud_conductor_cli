require 'json'
require 'active_support/inflector'

module CloudConductorCli
  module Helpers
    module Record
      def connection
        Connection.new(options[:host], options[:port])
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

      def find_id_by_name(model, name, parent_model: nil, parent_id: nil)
        records = list_records(model, parent_model: parent_model, parent_id: parent_id)
        result = records.find { |record| record['name'] == name }
        result = records.find { |record| record['id'].to_s == name.to_s } if result.nil?
        result.nil? ? nil : result['id']
      end

      def select_by_names(model, names, parent_model: nil, parent_id: nil)
        records = list_records(model, parent_model: parent_model, parent_id: parent_id)
        records.select do |record|
          names.include?(record['name']) || names.include?(record['id'].to_s)
        end
      end

      def pattern_parameters(pattern_names)
        pattern_names.each_with_object({}) do |pattern_name, result|
          pattern_id = find_id_by_name(:pattern, pattern_name)
          next if pattern_id.nil?
          response = connection.get("/patterns/#{pattern_id}/parameters")
          parameters = JSON.parse(response.body)
          result[pattern_name] = parameters
        end
      end

      def validate_parameter(options, input)
        if options['Type']
          case options['Type']
          when 'String', 'CommaDelimitedList'
            return false unless input.is_a? String
          when 'Number'
            return false unless input.is_a? Fixnum
          end
        end
        true
      end

      def clouds_with_priority(cloud_names)
        clouds = cloud_names.map.with_index do |cloud_name, index|
          {
            id: find_id_by_name(:cloud, cloud_name),
            priority: (cloud_names.size - index) * 10
          }
        end
        clouds.reject { |cloud| cloud[:id].nil? }
      end

      def stacks(options)
        if options['parameter_file']
          parameters = JSON.parse(File.read(options['parameter_file']))
        else
          parameters = input_template_parameters(options['patterns'])
        end
        if options['user_attribute_file']
          user_attributes = JSON.parse(File.read(options['user_attribute_file']))
        else
          user_attributes = {}
        end
        patterns = select_by_names(:pattern, options['patterns'])
        patterns.map do |pattern|
          template_parameters = parameters.key?(pattern['name']) ? parameters[pattern['name']] : {}
          attributes = user_attributes.key?(pattern['name']) ? user_attributes[pattern['name']] : {}
          {
            name: "#{options['name']}-#{pattern['name']}".gsub(/_/, '-'),
            pattern_id: pattern['id'],
            template_parameters: JSON.dump(template_parameters),
            parameters: JSON.dump(attributes)
          }
        end
      end

      def targets(options)
        [{
          operating_system_id: 1,
          source_image: source_image(options),
          ssh_username: 'ec2-user'
        }]
      end

      def source_image(options)
        # TODO: Fix CloudConductor Server
        aws_base_images = {
          'ap-northeast-1' => 'ami-9b4b789a',
          'ap-southeast-1' => 'ami-0eb7965c',
          'ap-southeast-2' => 'ami-c50864ff',
          'eu-west-1' => 'ami-9210bee5',
          'eu-central-1' => 'ami-bc0234a1',
          'sa-east-1' => 'ami-ab0fbbb6',
          'us-east-1' => 'ami-5452d53c',
          'us-west-1' => 'ami-5940541c',
          'us-west-2' => 'ami-575c1267'
        }
        case options['type']
        when 'aws'
          aws_base_images[options['entry_point']]
        when 'openstack'
          options['base_image_id']
        end
      end
    end
  end
end
