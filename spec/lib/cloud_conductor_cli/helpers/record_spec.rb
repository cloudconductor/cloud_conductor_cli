require 'active_support/core_ext'

module CloudConductorCli
  module Helpers
    describe Record do
      let(:record) { Object.new.extend(Record) }
      let(:model) { :project }
      let(:mock_project) { { id: 1, name: 'project_name', description: 'project_description' } }
      let(:get_params) { {} }

      before do
        allow(Connection).to receive(:new).and_return(double(get: true, post: true, put: true, delete: true, request: true))
        allow(record).to receive(:options).and_return(host: 'dummy_host', port: 9999)
      end

      describe '#connection' do
        it 'returns Connection instance' do
          expect(Connection).to receive(:new).with('dummy_host', 9999)
          record.connection
        end
      end

      describe '#declared' do
      end

      describe '#list_records' do
        before do
          mock_response = double(status: 200, headers: [], body: JSON.dump([mock_project]))
          allow(record.connection).to receive(:get).with("/#{model.to_s.pluralize}", get_params).and_return(mock_response)
        end

        it 'request GET /:models' do
          expect(record.connection).to receive(:get).with("/#{model.to_s.pluralize}", get_params)
          record.list_records(model)
        end

        it 'returns specified model records' do
          result = record.list_records(model)
          expect(result).to match_array([mock_project.stringify_keys])
        end
      end

      describe '#where' do
        before do
          mock_projects = [mock_project, mock_project.merge(id: 2, name: 'new_project')]
          allow(record).to receive(:list_records).and_return(mock_projects.map(&:stringify_keys))
        end

        it 'call list_records' do
          expect(record).to receive(:list_records)
          record.where(model, name: 'project_name')
        end

        it 'returns filtered records' do
          result = record.where(model, name: 'project_name')
          expect(result).to match([mock_project.stringify_keys])
        end
      end

      describe '#find_by' do
        before do
          allow(record).to receive(:where).and_return([mock_project.stringify_keys])
        end

        it 'call where' do
          expect(record).to receive(:where)
          record.find_by(model, name: 'project_name')
        end

        it 'returns first matched record' do
          result = record.find_by(model, name: 'project_name')
          expect(result).to match(mock_project.stringify_keys)
        end
      end

      describe '#find_id_by' do
        before do
          allow(record).to receive(:find_by).and_return(mock_project.stringify_keys)
        end

        it 'call find_by' do
          expect(record).to receive(:find_by).with(model, { name: 'project_name' }, {})
          record.find_id_by(model, :name, 'project_name')
        end

        it 'returns id of matched record' do
          result = record.find_id_by(model, :name, 'project_name')
          expect(result).to eq(mock_project[:id])
        end
      end

      describe '#template_parameters' do
        let(:mock_response_body) do
          '{ "sample_pattern": {} }'
        end
        let(:mock_response) { double(status: 200, headers: [], body: mock_response_body) }

        before do
          allow(record).to receive(:find_id_by).with(:blueprint, :name, 'blueprint_name').and_return(1)
          allow(record.connection).to receive(:get).with('/blueprints/1/histories/1/parameters', anything).and_return(mock_response)
        end

        it 'request GET /blueprint/:id/histories/:version/parameters with cloud' do
          expect(record.connection).to receive(:get).with('/blueprints/1/histories/1/parameters', cloud_ids: '1')
          record.template_parameters('blueprint_name', 1, '1')
        end

        it 'returns template parameters' do
          result = record.template_parameters('blueprint_name', 1, '1')
          expect(result).to match(JSON.parse(mock_response_body))
        end
      end

      describe '#default_parameters' do
        let(:template_parameters) do
          {
            'sample_pattern' => {
              'cloud_formation' => {
                'Parameter1' => {
                  'Type' => 'String',
                  'Description' => 'test1',
                  'Default' => 'default1'
                }
              },
              'terraform' => {
                'aws' => {
                  'parameter2' => {
                    'description' => 'test2',
                    'default' => 'default2'
                  }
                },
                'openstack' => {
                  'parameter2' => {
                    'description' => 'test2',
                    'default' => 'default2'
                  }
                }
              }
            }
          }
        end

        before do
          allow(record).to receive(:template_parameters).and_return(template_parameters)
        end

        it 'extract default value from template_parameters' do
          result = record.default_parameters('blueprint1', '1', '1, 2')
          expect(result).to eq(
            'sample_pattern' => {
              'cloud_formation' => {
                'Parameter1' => {
                  'type' => 'static',
                  'value' => 'default1'
                }
              },
              'terraform' => {
                'aws' => {
                  'parameter2' => {
                    'type' => 'static',
                    'value' => 'default2'
                  }
                },
                'openstack' => {
                  'parameter2' => {
                    'type' => 'static',
                    'value' => 'default2'
                  }
                }
              }
            }
          )
        end
      end

      describe '#build_template_parameters' do
        let(:default_parameters) do
          {
            'sample_pattern' => {
              'cloud_formation' => {
                'Parameter1' => {
                  'type' => 'static',
                  'value' => 'default1'
                }
              },
              'terraform' => {
                'aws' => {
                  'parameter2' => {
                    'type' => 'static',
                    'value' => 'default2'
                  }
                },
                'openstack' => {
                  'parameter2' => {
                    'type' => 'static',
                    'value' => 'default2'
                  }
                }
              }
            }
          }
        end
        let(:options) do
          {
            name: 'environment_name',
            blueprint: 'blueprint_name',
            version: 1,
            parameter_file: '/path/to/parameter_file',
            user_attribute_file: '/path/to/user_attribute_file'
          }.stringify_keys
        end
        let(:parameter_file) do
          JSON.dump(
            sample_pattern: {
              cloud_formation: {
                Parameter1: {
                  type: :static,
                  value: 'test1'
                },
                ParameterNew: {
                  type: :static,
                  value: 10
                }
              },
              terraform: {
                aws: {
                  parameter2: {
                    type: :module,
                    value: 'common_network.subnet_ids'
                  }
                },
                openstack: {
                }
              }
            }
          )
        end
        let(:user_attribute_file) do
          JSON.dump(cookbook_name: {
                      key1: 'value1'
                    })
        end

        before do
          allow(record).to receive(:get_latest_version).and_return(1)
          allow(record).to receive(:input_template_parameters).and_return(JSON.parse(parameter_file))
          allow(File).to receive(:read).with('/path/to/parameter_file').and_return(parameter_file)
          allow(File).to receive(:read).with('/path/to/user_attribute_file').and_return(user_attribute_file)
        end

        context 'with parameter_file' do
          before do
            allow(record).to receive(:default_parameters).and_return(default_parameters)
          end

          it 'will not calll #get_latest_version when options does not contain version' do
            expect(record).not_to receive(:get_latest_version)
            record.build_template_parameters(nil, options, '1')
          end

          it 'will calll #get_latest_version when options does not contain version' do
            expect(record).to receive(:get_latest_version)
            record.build_template_parameters(nil, options.except('version'), '1')
          end

          it 'call File.read' do
            expect(File).to receive(:read).with('/path/to/parameter_file')
            record.build_template_parameters(nil, options, '1')
          end

          it 'returns template_parameters which merged default and specified file' do
            expected_json = JSON.dump(
              'sample_pattern' => {
                'cloud_formation' => {
                  'Parameter1' => {
                    'type' => 'static',
                    'value' => 'test1'
                  },
                  ParameterNew: {
                    type: :static,
                    value: 10
                  }
                },
                'terraform' => {
                  'aws' => {
                    'parameter2' => {
                      type: :module,
                      value: 'common_network.subnet_ids'
                    }
                  },
                  'openstack' => {
                    'parameter2' => {
                      'type' => 'static',
                      'value' => 'default2'
                    }
                  }
                }
              }
            )

            result = record.build_template_parameters(nil, options, '1')
            expect(result).to eq(expected_json)
          end
        end

        context 'without parameter_file' do
          context 'with options[:blueprint]' do
            it 'call input_template_parameters' do
              expect(record).to receive(:input_template_parameters).with(options['blueprint'], 1, '1')
              record.build_template_parameters(nil, options.except('parameter_file'), '1')
            end

            it 'returns template_parameters' do
              result = record.build_template_parameters(nil, options.except('parameter_file'), '1')
              expect(result).to eq(parameter_file)
            end
          end

          context 'without options[:blueprint]' do
            let(:new_options) { options.except('parameter_file', 'blueprint') }
            before do
              allow(record).to receive(:get_latest_history_from_environment).and_return(
                'blueprint_id' => 1,
                'version' => 1
              )
            end

            it 'call #get_latest_history_from_environment' do
              expect(record).to receive(:get_latest_history_from_environment)
              record.build_template_parameters('environment_name', new_options, '1')
            end

            it 'call input_template_parameters' do
              expect(record).to receive(:input_template_parameters).with(1, 1, '1')
              record.build_template_parameters('environment_name', new_options, '1')
            end

            it 'returns template_parameters' do
              result = record.build_template_parameters('environment_name', new_options, '1')
              expect(result).to eq(parameter_file)
            end
          end
        end
      end

      describe '#get_latest_version' do
        let(:mock_blueprint) { { id: 1 }.stringify_keys }
        let(:mock_histories) do
          [
            { id: 1, version: 1, blueprint_id: 1 }.stringify_keys,
            { id: 2, version: 3, blueprint_id: 1 }.stringify_keys
          ]
        end

        before do
          allow(record).to receive(:find_id_by).with(:blueprint, :name, 'blueprint_name').and_return(1)
          allow(record).to receive(:list_records).with(:histories, parent_model: :blueprint, parent_id: 1).and_return(mock_histories)
        end

        it 'return nil when blueprint_name does not specified' do
          expect(record.get_latest_version(nil)).to be_nil
        end

        it 'return latest version of histories which depend on specified blueprint' do
          expect(record.get_latest_version('blueprint_name')).to eq(3)
        end
      end

      describe '#get_latest_history_from_environment' do
        let(:mock_environment) { { id: 1, blueprint_history_id: 1, system_id: 1, name: 'environment_name' }.stringify_keys }
        let(:mock_blueprint) { { id: 1 }.stringify_keys }
        let(:mock_blueprint_history) { { id: 1, version: 1, blueprint_id: 1 }.stringify_keys }
        before do
          allow(record).to receive(:find_id_by).with(:environment, :name, 'environment_name').and_return(1)
          allow(record).to receive(:find_by).with(:environment, id: 1).and_return(mock_environment)
          allow(record).to receive(:list_records).with(:blueprint).and_return([mock_blueprint])
          allow(record).to receive(:list_records).with(:histories, parent_model: :blueprint, parent_id: 1).and_return([mock_blueprint_history])
        end

        it 'return latest version in histories' do
          expect(record.get_latest_history_from_environment('environment_name')).to eq(mock_blueprint_history)
        end
      end
    end
  end
end
