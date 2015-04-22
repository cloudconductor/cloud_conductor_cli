require 'active_support/core_ext'

module CloudConductorCli
  module Models
    describe System do
      let(:system) { CloudConductorCli::Models::System.new }
      let(:commands) { CloudConductorCli::Models::System.commands }
      let(:mock_system) do
        {
          id: 1,
          project_id: 1,
          name: 'system_name',
          description: 'system_description',
          domain: 'test.example.com',
          primary_environment_id: nil
        }
      end

      before do
        allow(CloudConductorCli::Helpers::Connection).to receive(:new).and_return(double(get: true, post: true, put: true, delete: true, request: true))
        allow(system).to receive(:find_id_by).with(:system, :name, anything).and_return(mock_system[:id])
        allow(system).to receive(:find_id_by).with(:project, :name, anything).and_return(1)
        allow(system).to receive(:find_id_by).with(:environment, :name, anything).and_return(1)
        allow(system).to receive(:output)
        allow(system).to receive(:display_message)
      end

      describe '#list' do
        let(:mock_response) { double(status: 200, headers: [], body: JSON.dump([mock_system])) }
        before do
          allow(system.connection).to receive(:get).with('/systems').and_return(mock_response)
        end

        it 'allow valid options' do
          allowed_options = []
          expect(commands['list'].options.keys).to match_array(allowed_options)
        end

        it 'request GET /systems' do
          expect(system.connection).to receive(:get).with('/systems')
          system.list
        end

        it 'display record list' do
          expect(system).to receive(:output).with(mock_response)
          system.list
        end
      end

      describe '#show' do
        let(:mock_response) { double(status: 200, headers: [], body: JSON.dump(mock_system)) }
        before do
          allow(system.connection).to receive(:get).with("/systems/#{mock_system[:id]}").and_return(mock_response)
        end

        it 'allow valid options' do
          allowed_options = []
          expect(commands['show'].options.keys).to match_array(allowed_options)
        end

        it 'request GET /systems/:id' do
          expect(system.connection).to receive(:get).with("/systems/#{mock_system[:id]}")
          system.show('system_name')
        end

        it 'display record details' do
          expect(system).to receive(:output).with(mock_response)
          system.show('system_name')
        end
      end

      describe '#create' do
        let(:mock_response) { double(status: 201, headers: [], body: JSON.dump(mock_system)) }
        before do
          allow(system.connection).to receive(:post).with('/systems', anything).and_return(mock_response)
        end

        it 'allow valid options' do
          allowed_options = [:project, :name, :description, :domain]
          expect(commands['create'].options.keys).to match_array(allowed_options)
        end

        it 'request POST /systems with payload' do
          system.options = mock_system.except(:id, :project_id, :primary_environment_id).merge('project' => 'project_name')
          payload = system.options.except('project').merge('project_id' => 1)
          expect(system.connection).to receive(:post).with('/systems', payload)
          system.create
        end

        it 'display message and record details' do
          expect(system).to receive(:display_message)
          expect(system).to receive(:output).with(mock_response)
          system.create
        end
      end

      describe '#update' do
        let(:mock_response) { double(status: 200, headers: [], body: JSON.dump(mock_system)) }
        before do
          allow(system.connection).to receive(:put).with("/systems/#{mock_system[:id]}", anything).and_return(mock_response)
        end

        it 'allow valid options' do
          allowed_options = [:name, :description, :domain]
          expect(commands['update'].options.keys).to match_array(allowed_options)
        end

        it 'request PUT /systems/:id with payload' do
          system.options = mock_system.except(:id, :project_id, :primary_environment_id)
          payload = system.options
          expect(system.connection).to receive(:put).with("/systems/#{mock_system[:id]}", payload)
          system.update('system_name')
        end

        it 'display message and record details' do
          expect(system).to receive(:display_message)
          expect(system).to receive(:output).with(mock_response)
          system.update('system_name')
        end
      end

      describe '#delete' do
        let(:mock_response) { double(status: 204, headers: [], body: JSON.dump('')) }
        before do
          allow(system.connection).to receive(:delete).with("/systems/#{mock_system[:id]}").and_return(mock_response)
        end

        it 'allow valid options' do
          allowed_options = []
          expect(commands['delete'].options.keys).to match_array(allowed_options)
        end

        it 'request DELETE /systems/:id' do
          expect(system.connection).to receive(:delete).with("/systems/#{mock_system[:id]}")
          system.delete('system_name')
        end

        it 'display message' do
          expect(system).to receive(:display_message)
          system.delete('system_name')
        end
      end

      describe '#switch' do
        let(:mock_response) { double(status: 200, headers: [], body: JSON.dump(mock_system.merge(primary_environment_id: 1))) }
        before do
          allow(system.connection).to receive(:put).with("/systems/#{mock_system[:id]}/switch", anything).and_return(mock_response)
        end

        it 'allow valid options' do
          allowed_options = [:environment]
          expect(commands['switch'].options.keys).to match_array(allowed_options)
        end

        it 'request PUT /systems/:id/switch with payload' do
          system.options = { 'environment' => 'environment_name' }
          payload = { 'environment_id' => 1 }
          expect(system.connection).to receive(:put).with("/systems/#{mock_system[:id]}/switch", payload)
          system.switch('system_name')
        end

        it 'display message and record details' do
          system.options = { 'environment' => 'environment_name' }
          expect(system).to receive(:display_message)
          expect(system).to receive(:output).with(mock_response)
          system.switch('system_name')
        end
      end
    end
  end
end
