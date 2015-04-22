require 'active_support/core_ext'

module CloudConductorCli
  module Models
    describe Cloud do
      let(:cloud) { CloudConductorCli::Models::Cloud.new }
      let(:commands) { CloudConductorCli::Models::Cloud.commands }
      let(:mock_cloud) do
        {
          id: 1,
          project_id: 1,
          name: 'cloud_name',
          type: 'aws',
          entry_point: 'ap-northeast-1',
          key: 'access_key',
          secret: '********',
          tenant_name: nil
        }
      end

      before do
        allow(CloudConductorCli::Helpers::Connection).to receive(:new).and_return(double(get: true, post: true, put: true, delete: true, request: true))
        allow(cloud).to receive(:find_id_by).with(:cloud, :name, anything).and_return(mock_cloud[:id])
        allow(cloud).to receive(:find_id_by).with(:project, :name, anything).and_return(1)
        allow(cloud).to receive(:output)
        allow(cloud).to receive(:display_message)
      end

      describe '#list' do
        let(:mock_response) { double(status: 200, headers: [], body: JSON.dump([mock_cloud])) }
        before do
          allow(cloud.connection).to receive(:get).with('/clouds').and_return(mock_response)
        end

        it 'allow valid options' do
          allowed_options = []
          expect(commands['list'].options.keys).to match_array(allowed_options)
        end

        it 'request GET /clouds' do
          expect(cloud.connection).to receive(:get).with('/clouds')
          cloud.list
        end

        it 'display record list' do
          expect(cloud).to receive(:output).with(mock_response)
          cloud.list
        end
      end

      describe '#show' do
        let(:mock_response) { double(status: 200, headers: [], body: JSON.dump(mock_cloud)) }
        before do
          allow(cloud.connection).to receive(:get).with("/clouds/#{mock_cloud[:id]}").and_return(mock_response)
        end

        it 'allow valid options' do
          allowed_options = []
          expect(commands['show'].options.keys).to match_array(allowed_options)
        end

        it 'request GET /clouds/:id' do
          expect(cloud.connection).to receive(:get).with("/clouds/#{mock_cloud[:id]}")
          cloud.show('cloud_name')
        end

        it 'display record details' do
          expect(cloud).to receive(:output).with(mock_response)
          cloud.show('cloud_name')
        end
      end

      describe '#create' do
        let(:mock_response) { double(status: 201, headers: [], body: JSON.dump(mock_cloud)) }
        before do
          allow(cloud.connection).to receive(:post).with('/clouds', anything).and_return(mock_response)
        end

        it 'allow valid options' do
          allowed_options = [:project, :name, :type, :entry_point, :key, :secret, :description, :tenant_name]
          expect(commands['create'].options.keys).to match_array(allowed_options)
        end

        it 'request POST /clouds with payload' do
          cloud.options = mock_cloud.except(:id, :project_id).merge('project' => 'project_name', 'secret' => 'secret_key')
          payload = cloud.options.except('project').merge('project_id' => 1)
          expect(cloud.connection).to receive(:post).with('/clouds', payload)
          cloud.create
        end

        it 'display message and record details' do
          expect(cloud).to receive(:display_message)
          expect(cloud).to receive(:output).with(mock_response)
          cloud.create
        end
      end

      describe '#update' do
        let(:mock_response) { double(status: 200, headers: [], body: JSON.dump(mock_cloud)) }
        before do
          allow(cloud.connection).to receive(:put).with("/clouds/#{mock_cloud[:id]}", anything).and_return(mock_response)
        end

        it 'allow valid options' do
          allowed_options = [:name, :type, :entry_point, :key, :secret, :description, :tenant_name]
          expect(commands['update'].options.keys).to match_array(allowed_options)
        end

        it 'request PUT /clouds/:id with payload' do
          cloud.options = mock_cloud.except(:id, :project_id).merge(secret: 'secret_key')
          payload = cloud.options
          expect(cloud.connection).to receive(:put).with("/clouds/#{mock_cloud[:id]}", payload)
          cloud.update('cloud_name')
        end

        it 'display message and record details' do
          expect(cloud).to receive(:display_message)
          expect(cloud).to receive(:output).with(mock_response)
          cloud.update('cloud_name')
        end
      end

      describe '#delete' do
        let(:mock_response) { double(status: 204, headers: [], body: JSON.dump('')) }
        before do
          allow(cloud.connection).to receive(:delete).with("/clouds/#{mock_cloud[:id]}").and_return(mock_response)
        end

        it 'allow valid options' do
          allowed_options = []
          expect(commands['delete'].options.keys).to match_array(allowed_options)
        end

        it 'request DELETE /clouds/:id' do
          expect(cloud.connection).to receive(:delete).with("/clouds/#{mock_cloud[:id]}")
          cloud.delete('cloud_name')
        end

        it 'display message' do
          expect(cloud).to receive(:display_message)
          cloud.delete('cloud_name')
        end
      end
    end
  end
end
