require 'active_support/core_ext'

module CloudConductorCli
  module Models
    describe Environment do
      let(:environment) { CloudConductorCli::Models::Environment.new }
      let(:commands) { CloudConductorCli::Models::Environment.commands }
      let(:mock_environment) do
        {
          id: 1,
          system_id: 1,
          blueprint_id: 1,
          name: 'environment_name',
          description: 'environment_description',
          status: 'CREATE_COMPLETE',
          ip_address: '127.0.0.1',
          template_parameters: '{}'
        }
      end

      before do
        allow(environment).to receive(:find_id_by).with(:environment, :name, anything).and_return(mock_environment[:id])
        allow(environment).to receive(:find_id_by).with(:system, :name, anything).and_return(1)
        allow(environment).to receive(:find_id_by).with(:blueprint, :name, anything).and_return(1)
        allow(environment).to receive(:find_id_by).with(:cloud, :name, anything).and_return(1)
        allow(environment).to receive(:display_message)
        allow(environment).to receive(:display_list)
        allow(environment).to receive(:display_details)
      end

      describe '#list' do
        let(:mock_response) { double(status: 200, headers: [], body: JSON.dump([mock_environment])) }
        before do
          allow(environment.connection).to receive(:get).with('/environments').and_return(mock_response)
        end

        it 'allow valid options' do
          allowed_options = []
          expect(commands['list'].options.keys).to match_array(allowed_options)
        end

        it 'request GET /environments' do
          expect(environment.connection).to receive(:get).with('/environments')
          environment.list
        end

        it 'display record list' do
          expect(environment).to receive(:display_list).with([mock_environment.stringify_keys])
          environment.list
        end
      end

      describe '#show' do
        let(:mock_response) { double(status: 200, headers: [], body: JSON.dump(mock_environment)) }
        before do
          allow(environment.connection).to receive(:get).with("/environments/#{mock_environment[:id]}").and_return(mock_response)
        end

        it 'allow valid options' do
          allowed_options = []
          expect(commands['show'].options.keys).to match_array(allowed_options)
        end

        it 'request GET /environments/:id' do
          expect(environment.connection).to receive(:get).with("/environments/#{mock_environment[:id]}")
          environment.show('environment_name')
        end

        it 'display record details' do
          expect(environment).to receive(:display_details).with(mock_environment.stringify_keys)
          environment.show('environment_name')
        end
      end

      describe '#create' do
        let(:mock_response) { double(status: 201, headers: [], body: JSON.dump(mock_environment)) }
        before do
          allow(environment.connection).to receive(:post).with('/environments', anything).and_return(mock_response)
          allow(environment).to receive(:build_template_parameters).and_return('{}')
          allow(environment).to receive(:build_user_attributes).and_return('{}')
        end

        it 'allow valid options' do
          allowed_options = [:blueprint, :clouds, :description, :name, :parameter_file, :system, :user_attribute_file]
          expect(commands['create'].options.keys).to match_array(allowed_options)
        end

        it 'request POST /environments with payload' do
          environment.options = mock_environment.except(:id, :system_id, :blueprint_id, :template_parameters, :status, :ip_address)
            .merge('system' => 'system_name', 'blueprint' => 'blueprint_name', 'clouds' => ['cloud_name'])
          payload = environment.options.except('system', 'blueprint', 'clouds')
                    .merge('system_id' => 1, 'blueprint_id' => 1, 'candidates_attributes' => [{ cloud_id: 1, priority: 10 }],
                           'template_parameters' => '{}', 'user_attributes' => '{}')
          expect(environment.connection).to receive(:post).with('/environments', payload)
          environment.create
        end

        it 'display message and record details' do
          environment.options = mock_environment.except(:id, :system_id, :blueprint_id, :template_parameters, :status, :ip_address)
            .merge('system' => 'system_name', 'blueprint' => 'blueprint_name', 'clouds' => ['cloud_name'])
          expect(environment).to receive(:display_message)
          expect(environment).to receive(:display_details).with(mock_environment.stringify_keys)
          environment.create
        end
      end

      describe '#update' do
        let(:mock_response) { double(status: 200, headers: [], body: JSON.dump(mock_environment)) }
        before do
          allow(environment.connection).to receive(:put).with("/environments/#{mock_environment[:id]}", anything).and_return(mock_response)
        end

        it 'allow valid options' do
          allowed_options = [:clouds, :description, :name, :parameter_file, :user_attribute_file]
          expect(commands['update'].options.keys).to match_array(allowed_options)
        end

        it 'request PUT /environments/:id with payload' do
          environment.options = mock_environment.except(:id, :system_id, :blueprint_id, :template_parameters, :status, :ip_address)
            .merge('clouds' => ['cloud_name'])
          payload = environment.options.except('clouds').merge('candidates_attributes' => [{ cloud_id: 1, priority: 10 }])
          expect(environment.connection).to receive(:put).with("/environments/#{mock_environment[:id]}", payload)
          environment.update('environment_name')
        end

        it 'display message and record details' do
          expect(environment).to receive(:display_message)
          expect(environment).to receive(:display_details).with(mock_environment.stringify_keys)
          environment.update('environment_name')
        end
      end

      describe '#delete' do
        let(:mock_response) { double(status: 204, headers: [], body: JSON.dump('')) }
        before do
          allow(environment.connection).to receive(:delete).with("/environments/#{mock_environment[:id]}").and_return(mock_response)
        end

        it 'allow valid options' do
          allowed_options = []
          expect(commands['delete'].options.keys).to match_array(allowed_options)
        end

        it 'request DELETE /environments/:id' do
          expect(environment.connection).to receive(:delete).with("/environments/#{mock_environment[:id]}")
          environment.delete('environment_name')
        end

        it 'display message' do
          expect(environment).to receive(:display_message)
          environment.delete('environment_name')
        end
      end
    end
  end
end
