require 'active_support/core_ext'

module CloudConductorCli
  module Models
    describe Blueprint do
      let(:blueprint) { CloudConductorCli::Models::Blueprint.new }
      let(:commands) { CloudConductorCli::Models::Blueprint.commands }
      let(:mock_blueprint) do
        {
          id: 1,
          project_id: 1,
          name: 'blueprint_name',
          description: 'blueprint description'
        }
      end

      before do
        allow(CloudConductorCli::Helpers::Connection).to receive(:new).and_return(double(get: true, post: true, put: true, delete: true, request: true))
        allow(blueprint).to receive(:find_id_by).with(:blueprint, :name, anything).and_return(mock_blueprint[:id])
        allow(blueprint).to receive(:find_id_by).with(:project, :name, anything).and_return(1)
        allow(blueprint).to receive(:output)
        allow(blueprint).to receive(:message)
      end

      describe '#list' do
        let(:mock_response) { double(status: 200, headers: [], body: JSON.dump([mock_blueprint])) }
        before do
          allow(blueprint.connection).to receive(:get).with('/blueprints').and_return(mock_response)
        end

        it 'allow valid options' do
          allowed_options = []
          expect(commands['list'].options.keys).to match_array(allowed_options)
        end

        it 'request GET /blueprints' do
          expect(blueprint.connection).to receive(:get).with('/blueprints')
          blueprint.list
        end

        it 'display record list' do
          expect(blueprint).to receive(:output).with(mock_response)
          blueprint.list
        end
      end

      describe '#show' do
        let(:mock_response) { double(status: 200, headers: [], body: JSON.dump(mock_blueprint)) }
        before do
          allow(blueprint.connection).to receive(:get).with("/blueprints/#{mock_blueprint[:id]}").and_return(mock_response)
        end

        it 'allow valid options' do
          allowed_options = []
          expect(commands['show'].options.keys).to match_array(allowed_options)
        end

        it 'request GET /blueprints/:id' do
          expect(blueprint.connection).to receive(:get).with("/blueprints/#{mock_blueprint[:id]}")
          blueprint.show('blueprint_name')
        end

        it 'display record details' do
          expect(blueprint).to receive(:output).with(mock_response)
          blueprint.show('blueprint_name')
        end
      end

      describe '#create' do
        let(:mock_response) { double(status: 201, headers: [], body: JSON.dump(mock_blueprint)) }
        before do
          allow(blueprint.connection).to receive(:post).with('/blueprints', anything).and_return(mock_response)
        end

        it 'allow valid options' do
          allowed_options = [:project, :name, :description]
          expect(commands['create'].options.keys).to match_array(allowed_options)
        end

        it 'request POST /blueprints with payload' do
          blueprint.options = mock_blueprint.except(:id, :project_id).merge(project: 'project_name')
          payload = blueprint.options.except(:project).merge(project_id: 1)
          expect(blueprint.connection).to receive(:post).with('/blueprints', payload)
          blueprint.create
        end

        it 'display message and record details' do
          expect(blueprint).to receive(:message)
          expect(blueprint).to receive(:output).with(mock_response)
          blueprint.create
        end
      end

      describe '#update' do
        let(:mock_response) { double(status: 200, headers: [], body: JSON.dump(mock_blueprint)) }
        before do
          allow(blueprint.connection).to receive(:put).with("/blueprints/#{mock_blueprint[:id]}", anything).and_return(mock_response)
        end

        it 'allow valid options' do
          allowed_options = [:name, :description]
          expect(commands['update'].options.keys).to match_array(allowed_options)
        end

        it 'request PUT /blueprints/:id with payload' do
          blueprint.options = mock_blueprint.except(:id, :project_id)
          expect(blueprint.connection).to receive(:put).with("/blueprints/#{mock_blueprint[:id]}", blueprint.options)
          blueprint.update('blueprint_name')
        end

        it 'display message and record details' do
          expect(blueprint).to receive(:message)
          expect(blueprint).to receive(:output).with(mock_response)
          blueprint.update('blueprint_name')
        end
      end

      describe '#delete' do
        let(:mock_response) { double(status: 204, headers: [], body: JSON.dump('')) }
        before do
          allow(blueprint.connection).to receive(:delete).with("/blueprints/#{mock_blueprint[:id]}").and_return(mock_response)
        end

        it 'allow valid options' do
          allowed_options = []
          expect(commands['delete'].options.keys).to match_array(allowed_options)
        end

        it 'request DELETE /blueprints/:id' do
          expect(blueprint.connection).to receive(:delete).with("/blueprints/#{mock_blueprint[:id]}")
          blueprint.delete('blueprint_name')
        end

        it 'display message' do
          expect(blueprint).to receive(:message)
          blueprint.delete('blueprint_name')
        end
      end
    end
  end
end
