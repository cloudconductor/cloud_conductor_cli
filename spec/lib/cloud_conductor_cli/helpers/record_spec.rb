require 'active_support/core_ext'

module CloudConductorCli
  module Helpers
    describe Record do
      let(:record) { Object.new.extend(Record) }
      let(:model) { :project }
      let(:mock_project) { { id: 1, name: 'project_name', description: 'project_description' } }

      before do
        allow(Connection).to receive(:new).and_return(double(get: true, post: true, put: true, delete: true, request: true))
        allow(record).to receive(:options).and_return({ host: 'dummy_host', port: 99999 })
      end

      describe '#connection' do
        it 'returns Connection instance' do
          expect(Connection).to receive(:new).with('dummy_host', 99999)
          record.connection
        end
      end

      describe '#declared' do
      end

      describe '#list_records' do
        before do
          mock_response = double(status: 200, headers: [], body: JSON.dump([mock_project]))
          allow(record.connection).to receive(:get).with("/#{model.to_s.pluralize}").and_return(mock_response)
        end

        it 'request GET /:models' do
          expect(record.connection).to receive(:get).with("/#{model.to_s.pluralize}")
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
          expect(record).to receive(:find_by).with(model, { name: 'project_name' }, parent_model: nil, parent_id: nil)
          record.find_id_by(model, :name, 'project_name')
        end

        it 'returns id of matched record' do
          result = record.find_id_by(model, :name, 'project_name')
          expect(result).to eq(mock_project[:id])
        end
      end

      describe '#template_parameters' do
        let(:mock_response_body) do
          JSON.dump(sample_pattern: {
                      Parameter1: {
                        Type: 'String',
                        Description: 'test1'
                      },
                      Parameter2: {
                        Type: 'Number',
                        Description: 'test2'
                      },
                      Parameter3: {
                        Type: 'CommaDelimitedList',
                        Description: 'test3'
                      }
                    })
        end
        let(:mock_response) { double(status: 200, headers: [], body: mock_response_body) }

        before do
          allow(record).to receive(:find_id_by).with(:blueprint, :name, 'blueprint_name').and_return(1)
          allow(record.connection).to receive(:get).with('/blueprints/1/parameters').and_return(mock_response)
        end

        it 'request GET /blueprint/:id/parameters' do
          expect(record.connection).to receive(:get).with('/blueprints/1/parameters')
          record.template_parameters('blueprint_name')
        end

        it 'returns template parameters' do
          result = record.template_parameters('blueprint_name')
          expect(result).to match(JSON.parse(mock_response_body))
        end
      end

      describe '#build_template_parameters' do
        let(:mock_response_body) do
          JSON.dump(sample_pattern: {
                      Parameter1: {
                        Type: 'String',
                        Description: 'test1'
                      },
                      Parameter2: {
                        Type: 'Number',
                        Description: 'test2'
                      },
                      Parameter3: {
                        Type: 'CommaDelimitedList',
                        Description: 'test3'
                      }
                    })
        end
        let(:options) do
          {
            name: 'environment_name',
            blueprint: 'blueprint_name',
            parameter_file: '/path/to/parameter_file',
            user_attribute_file: '/path/to/user_attribute_file'
          }.stringify_keys
        end
        let(:parameter_file) do
          JSON.dump(sample_pattern: {
                      Parameter1: 'test1',
                      Parameter2: 10,
                      Parameter3: 'test1,test2,test3'
                    })
        end
        let(:user_attribute_file) do
          JSON.dump(cookbook_name: {
                      key1: 'value1'
                    })
        end

        before do
          allow(record).to receive(:input_template_parameters).and_return(JSON.parse(parameter_file))
          allow(File).to receive(:read).with('/path/to/parameter_file').and_return(parameter_file)
          allow(File).to receive(:read).with('/path/to/user_attribute_file').and_return(user_attribute_file)
        end

        context 'with parameter_file' do
          it 'call File.read' do
            expect(File).to receive(:read).with('/path/to/parameter_file')
            record.build_template_parameters(options)
          end

          it 'returns template_parameters' do
            result = record.build_template_parameters(options)
            expect(result).to eq(parameter_file)
          end
        end

        context 'without parameter_file' do
          context 'with options[:blueprint]' do
            it 'call input_template_parameters' do
              expect(record).to receive(:input_template_parameters).with(options['blueprint'])
              record.build_template_parameters(options.except('parameter_file'))
            end

            it 'returns template_parameters' do
              result = record.build_template_parameters(options.except('parameter_file'))
              expect(result).to eq(parameter_file)
            end
          end

          context 'without options[:blueprint]' do
            let(:new_options) { options.except('parameter_file', 'blueprint') }
            let(:mock_environment) { { id: 1, blueprint_id: 1, system_id: 1, name: 'environment_name' }.stringify_keys }
            before do
              allow(record).to receive(:find_by).with(:environment, name: 'environment_name').and_return(mock_environment)
            end

            it 'call input_template_parameters' do
              expect(record).to receive(:input_template_parameters).with(1)
              record.build_template_parameters(new_options)
            end

            it 'returns template_parameters' do
              result = record.build_template_parameters(new_options)
              expect(result).to eq(parameter_file)
            end
          end
        end
      end
    end
  end
end
