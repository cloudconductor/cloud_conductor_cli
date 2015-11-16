require 'active_support'
require 'active_support/core_ext'

module CloudConductorCli
  module Models
    describe Role do
      let(:role) { CloudConductorCli::Models::Role.new }
      let(:commands) { CloudConductorCli::Models::Role.commands }
      let(:mock_role) do
        {
          id: 1,
          project_id: 1,
          name: 'test_role',
          description: 'test_description'
        }
      end

      before do
        allow(CloudConductorCli::Helpers::Connection).to receive(:new).and_return(double(get: true, post: true, put: true, delete: true, request: true))
        allow(role).to receive(:find_id_by).with(:project, :name, anything).and_return(1)
        allow(role).to receive(:find_id_by).with(:role, :name, anything).and_return(mock_role[:id])
        allow(role).to receive(:find_id_by).with(:role, :name, anything, project_id: 1).and_return(mock_role[:id])
        allow(role).to receive(:output)
        allow(role).to receive(:message)
      end

      describe '#list' do
        let(:mock_response) { double(status: 200, headers: [], body: JSON.dump([mock_role])) }
        before do
          allow(role.connection).to receive(:get).with('/roles', anything).and_return(mock_response)
        end

        it 'allow valid options' do
          allowed_options = [:project]
          expect(commands['list'].options.keys).to match_array(allowed_options)
        end

        it 'request GET /roles' do
          expect(role.connection).to receive(:get).with('/roles', {})
          role.list
        end

        it 'display record list' do
          expect(role).to receive(:output).with(mock_response)
          role.list
        end
      end

      describe '#show' do
        let(:mock_response) { double(status: 200, headers: [], body: JSON.dump(mock_role)) }
        let(:mock_response_permissions) { double(status: 200, headers: [], body: JSON.dump('')) }
        before do
          allow(role.connection).to receive(:get).with("/roles/#{mock_role[:id]}").and_return(mock_response)
          allow(role.connection).to receive(:get).with("/roles/#{mock_role[:id]}/permissions").and_return(mock_response_permissions)
        end

        it 'allow valid options' do
          allowed_options = [:project]
          expect(commands['show'].options.keys).to match_array(allowed_options)
        end

        it 'request GET /roles/:id' do
          expect(role.connection).to receive(:get).with("/roles/#{mock_role[:id]}")
          role.show('role_name')
        end

        it 'request GET /roles/:id/permissions' do
          expect(role.connection).to receive(:get).with("/roles/#{mock_role[:id]}/permissions")
          role.show('role_name')
        end

        it 'display record details' do
          expect(role).to receive(:output).with(mock_response)
          expect(role).to receive(:message)
          expect(role).to receive(:output).with(mock_response_permissions)
          role.show('role_name')
        end
      end

      describe '#create' do
        let(:mock_response) { double(status: 201, headers: [], body: JSON.dump(mock_role)) }
        before do
          allow(role.connection).to receive(:post).with('/roles', anything).and_return(mock_response)
        end

        it 'allow valid options' do
          allowed_options = [:project, :name, :description]
          expect(commands['create'].options.keys).to match_array(allowed_options)
        end

        it 'request POST /roles' do
          role.options = mock_role.except(:id, :project_id).merge(project: 'project_name').with_indifferent_access
          payload = role.options.except(:project).merge(project_id: 1)
          expect(role.connection).to receive(:post).with('/roles', payload)
          role.create
        end

        it 'display message and record details' do
          expect(role).to receive(:message)
          expect(role).to receive(:output).with(mock_response)
          role.create
        end
      end

      describe '#update' do
        let(:mock_response) { double(status: 200, headers: [], body: JSON.dump(mock_role)) }
        before do
          allow(role.connection).to receive(:put).with("/roles/#{mock_role[:id]}", anything).and_return(mock_response)
        end

        it 'allow valid options' do
          allowed_options = [:project, :name, :description]
          expect(commands['update'].options.keys).to match_array(allowed_options)
        end

        it 'request PUT /roles/:id' do
          role.options = mock_role.except(:id, :project_id)
          payload = role.options
          expect(role.connection).to receive(:put).with("/roles/#{mock_role[:id]}", payload)
          role.update('role_name')
        end

        it 'display message and record details' do
          expect(role).to receive(:message)
          expect(role).to receive(:output).with(mock_response)
          role.update('role_name')
        end
      end

      describe '#delete' do
        let(:mock_response) { double(status: 204, headers: [], body: JSON.dump('')) }
        before do
          allow(role.connection).to receive(:delete).with("/roles/#{mock_role[:id]}").and_return(mock_response)
        end

        it 'allow valid options' do
          allowed_options = [:project]
          expect(commands['delete'].options.keys).to match_array(allowed_options)
        end

        it 'request DELETE /roles/:id' do
          expect(role.connection).to receive(:delete).with("/roles/#{mock_role[:id]}")
          role.delete('role_name')
        end

        it 'display message' do
          expect(role).to receive(:message)
          role.delete('role_name')
        end
      end

      describe '#add-permission' do
        let(:mock_response) { double(status: 201, headers: [], body: JSON.dump('')) }
        before do
          allow(role.connection).to receive(:post).with("/roles/#{mock_role[:id]}/permissions", anything).and_return(mock_response)
        end

        it 'allow valid options' do
          allowed_options = [:project, :model, :action]
          expect(commands['add_permission'].options.keys).to match_array(allowed_options)
        end

        it 'request POST /roles/:id/permission' do
          role.options = {
            model: 'test',
            action: 'manage'
          }
          payload = role.options
          expect(role.connection).to receive(:post).with("/roles/#{mock_role[:id]}/permissions", payload)
          role.add_permission('role_name')
        end

        it 'display message' do
          expect(role).to receive(:output).with(mock_response)
          role.add_permission('role_name')
        end
      end

      describe '#remove-permission' do
        let(:mock_permission) do
          {
            id: 1,
            role_id: 1,
            model: 'test',
            action: 'manage'
          }
        end
        let(:mock_response) { double(status: 204, headers: [], body: JSON.dump('')) }
        before do
          allow(role.connection).to receive(:delete).with("/roles/#{mock_role[:id]}/permissions/1").and_return(mock_response)
          allow(role).to receive(:where).with(:permission, { model: 'test' }, parent_model: :role, parent_id: 1).and_return([mock_permission.stringify_keys])
        end

        it 'allow valid options' do
          allowed_options = [:project, :model, :action]
          expect(commands['remove_permission'].options.keys).to match_array(allowed_options)
        end

        it 'request DELETE /roles/:id/permission/:id' do
          role.options = {
            model: 'test',
            action: 'manage'
          }
          expect(role.connection).to receive(:delete).with("/roles/#{mock_role[:id]}/permissions/1")
          role.remove_permission('role_name')
        end

        it 'display message' do
          role.options = {
            model: 'test',
            action: 'manage'
          }
          expect(role).to receive(:message)
          role.remove_permission('role_name')
        end
      end
    end
  end
end
