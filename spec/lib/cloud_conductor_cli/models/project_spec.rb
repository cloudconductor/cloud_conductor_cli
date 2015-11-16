require 'active_support'
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
        allow(project).to receive(:output)
        allow(project).to receive(:message)
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
          expect(project).to receive(:output).with(mock_response)
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
          expect(project).to receive(:output).with(mock_response)
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
          expect(project).to receive(:message)
          expect(project).to receive(:output).with(mock_response)
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
          expect(project).to receive(:message)
          expect(project).to receive(:output).with(mock_response)
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
          expect(project).to receive(:message)
          project.delete('project_name')
        end
      end

      describe '#list-account' do
        let(:mock_response) { double(status: 200, headers: [], body: JSON.dump('')) }
        before do
          allow(project.connection).to receive(:get).with('/accounts', anything).and_return(mock_response)
        end

        it 'allow valid options' do
          allowed_options = []
          expect(commands['list_account'].options.keys).to match_array(allowed_options)
        end

        it 'request GET /accounts' do
          project.options = {}
          payload = {
            'project_id' => 1
          }
          expect(project.connection).to receive(:get).with('/accounts', payload)
          project.list_account('project_name')
        end

        it 'display message' do
          expect(project).to receive(:output).with(mock_response)
          project.list_account('project_name')
        end
      end

      describe '#add-account' do
        let(:mock_response) { double(status: 201, headers: [], body: JSON.dump('')) }
        before do
          allow(project).to receive(:find_id_by).with(:project, :name, anything).and_return(1)
          allow(project).to receive(:find_id_by).with(:role, :name, anything, project_id: 1).and_return(1)
          allow(project.connection).to receive(:post).with('/accounts', anything).and_return(mock_response)
        end

        it 'allow valid options' do
          allowed_options = [:email, :name, :password, :role]
          expect(commands['add_account'].options.keys).to match_array(allowed_options)
        end

        it 'request POST /accounts' do
          project.options = {
            email: 'test_name@example.com',
            role: 'test_role'
          }.with_indifferent_access
          payload = {
            'email' => 'test_name@example.com',
            'project_id' => 1,
            'role_id' => 1,
            'name' => 'test_name',
            'password' => 'test_name',
            'password_confirmation' => 'test_name'
          }
          expect(project.connection).to receive(:post).with('/accounts', payload)
          project.add_account('project_name')
        end

        it 'display message' do
          project.options = {
            email: 'test_name@example.com',
            role: 'test_role'
          }.with_indifferent_access
          expect(project).to receive(:output).with(mock_response)
          project.add_account('project_name')
        end
      end

      describe '#remove-account' do
        let(:mock_response) { double(status: 204, headers: [], body: JSON.dump('')) }
        before do
          allow(project).to receive(:find_id_by).with(:project, :name, anything).and_return(1)
          allow(project).to receive(:find_id_by).with(:account, :email, anything, project_id: 1).and_return(1)
          allow(project).to receive(:find_id_by).with(:assignment, :account_id, anything, project_id: 1).and_return(1)
          allow(project.connection).to receive(:delete).with('/assignments', anything).and_return(mock_response)
        end

        it 'allow valid options' do
          allowed_options = [:account]
          expect(commands['remove_account'].options.keys).to match_array(allowed_options)
        end

        it 'request DELETE /assignments/:id' do
          project.options = {
            account: 'test_name@example.com'
          }
          expect(project.connection).to receive(:delete).with('/assignments/1')
          project.remove_account('project_name')
        end

        it 'display message' do
          expect(project).to receive(:message)
          project.remove_account('project_name')
        end
      end
    end
  end
end
