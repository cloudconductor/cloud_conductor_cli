require 'active_support/core_ext'

module CloudConductorCli
  module Models
    describe Project do
      let(:project) { CloudConductorCli::Models::Project.new }
      let(:commands) { CloudConductorCli::Models::Project.commands }
      let(:mock_project) do
        {
          id: 1,
          name: 'project_name',
          description: 'project_description'
        }
      end

      before do
        allow(CloudConductorCli::Helpers::Connection).to receive(:new).and_return(double(get: true, post: true, put: true, delete: true, request: true))
        allow(project).to receive(:find_id_by).with(:project, :name, anything).and_return(mock_project[:id])
        allow(project).to receive(:display_message)
        allow(project).to receive(:display_list)
        allow(project).to receive(:display_details)
      end

      describe '#list' do
        let(:mock_response) { double(status: 200, headers: [], body: JSON.dump([mock_project])) }
        before do
          allow(project.connection).to receive(:get).with('/projects').and_return(mock_response)
        end

        it 'allow valid options' do
          allowed_options = []
          expect(commands['list'].options.keys).to match_array(allowed_options)
        end

        it 'request GET /projects' do
          expect(project.connection).to receive(:get).with('/projects')
          project.list
        end

        it 'display record list' do
          expect(project).to receive(:display_list).with([mock_project.stringify_keys])
          project.list
        end
      end

      describe '#show' do
        let(:mock_response) { double(status: 200, headers: [], body: JSON.dump(mock_project)) }
        before do
          allow(project.connection).to receive(:get).with("/projects/#{mock_project[:id]}").and_return(mock_response)
        end

        it 'allow valid options' do
          allowed_options = []
          expect(commands['show'].options.keys).to match_array(allowed_options)
        end

        it 'request GET /projects/:id' do
          expect(project.connection).to receive(:get).with("/projects/#{mock_project[:id]}")
          project.show('project_name')
        end

        it 'display record details' do
          expect(project).to receive(:display_details).with(mock_project.stringify_keys)
          project.show('project_name')
        end
      end

      describe '#create' do
        let(:mock_response) { double(status: 201, headers: [], body: JSON.dump(mock_project)) }
        before do
          allow(project.connection).to receive(:post).with('/projects', anything).and_return(mock_response)
        end

        it 'allow valid options' do
          allowed_options = [:name, :description]
          expect(commands['create'].options.keys).to match_array(allowed_options)
        end

        it 'request POST /projects with payload' do
          project.options = mock_project.except(:id)
          payload = project.options
          expect(project.connection).to receive(:post).with('/projects', payload)
          project.create
        end

        it 'display message and record details' do
          expect(project).to receive(:display_message)
          expect(project).to receive(:display_details).with(mock_project.stringify_keys)
          project.create
        end
      end

      describe '#update' do
        let(:mock_response) { double(status: 200, headers: [], body: JSON.dump(mock_project)) }
        before do
          allow(project.connection).to receive(:put).with("/projects/#{mock_project[:id]}", anything).and_return(mock_response)
        end

        it 'allow valid options' do
          allowed_options = [:name, :description]
          expect(commands['update'].options.keys).to match_array(allowed_options)
        end

        it 'request PUT /projects/:id with payload' do
          project.options = mock_project.except(:id)
          payload = project.options
          expect(project.connection).to receive(:put).with("/projects/#{mock_project[:id]}", payload)
          project.update('project_name')
        end

        it 'display message and record details' do
          expect(project).to receive(:display_message)
          expect(project).to receive(:display_details).with(mock_project.stringify_keys)
          project.update('project_name')
        end
      end

      describe '#delete' do
        let(:mock_response) { double(status: 204, headers: [], body: JSON.dump('')) }
        before do
          allow(project.connection).to receive(:delete).with("/projects/#{mock_project[:id]}").and_return(mock_response)
        end

        it 'allow valid options' do
          allowed_options = []
          expect(commands['delete'].options.keys).to match_array(allowed_options)
        end

        it 'request DELETE /projects/:id' do
          expect(project.connection).to receive(:delete).with("/projects/#{mock_project[:id]}")
          project.delete('project_name')
        end

        it 'display message' do
          expect(project).to receive(:display_message)
          project.delete('project_name')
        end
      end
    end
  end
end
