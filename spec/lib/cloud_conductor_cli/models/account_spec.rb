require 'active_support/core_ext'

module CloudConductorCli
  module Models
    describe Account do
      let(:account) { CloudConductorCli::Models::Account.new }
      let(:commands) { CloudConductorCli::Models::Account.commands }
      let(:mock_account) do
        {
          id: 1,
          email: 'test@example.com',
          name: 'test user',
          admin: 0
        }
      end

      before do
        allow(CloudConductorCli::Helpers::Connection).to receive(:new).and_return(double(get: true, post: true, put: true, delete: true, request: true))
        allow(account).to receive(:find_id_by).with(:account, :email, anything).and_return(mock_account[:id])
        allow(account).to receive(:output)
        allow(account).to receive(:message)
      end

      describe '#list' do
        let(:mock_response) { double(status: 200, headers: [], body: JSON.dump([mock_account])) }
        before do
          allow(account.connection).to receive(:get).with('/accounts', {}).and_return(mock_response)
        end

        it 'allow valid options' do
          allowed_options = [:project]
          expect(commands['list'].options.keys).to match_array(allowed_options)
        end

        it 'request GET /accounts' do
          expect(account.connection).to receive(:get).with('/accounts', {})
          account.list
        end

        it 'display record list' do
          expect(account).to receive(:output).with(mock_response)
          account.list
        end

        context 'with project' do
          it 'request GET /accounts' do
            account.options = { project: 'project_name' }.with_indifferent_access

            expect(account).to receive(:find_id_by).with(:project, :name, 'project_name').and_return(1)

            expect(account.connection).to receive(:get).with('/accounts', 'project_id' => 1)
            account.list
          end
        end
      end

      describe '#show' do
        let(:mock_response) { double(status: 200, headers: [], body: JSON.dump(mock_account)) }
        before do
          allow(account.connection).to receive(:get).with("/accounts/#{mock_account[:id]}", {}).and_return(mock_response)
        end

        it 'allow valid options' do
          allowed_options = [:project]
          expect(commands['show'].options.keys).to match_array(allowed_options)
        end

        it 'request GET /accounts/:id' do
          expect(account.connection).to receive(:get).with("/accounts/#{mock_account[:id]}", {})
          account.show('test@example.com')
        end

        it 'display record details' do
          expect(account).to receive(:output).with(mock_response)
          account.show('test@example.com')
        end

        context 'with project' do
          let(:mock_response_role) { double(status: 200, headers: [], body: JSON.dump('')) }

          before do
            allow(account).to receive(:find_id_by).with(:project, :name, 'project_name').and_return(1)
            allow(account).to receive(:find_id_by).with(:account, :email, 'test@example.com', project_id: 1).and_return(mock_account[:id])
            allow(account.connection).to receive(:get).with("/accounts/#{mock_account[:id]}", project_id: 1).and_return(mock_response)
            allow(account.connection).to receive(:get).with('/roles', project_id: 1, account_id: mock_account[:id]).and_return(mock_response_role)
            account.options = { project: 'project_name' }.with_indifferent_access
          end

          it 'request GET /accounts/:id' do
            expect(account).to receive(:find_id_by).with(:project, :name, 'project_name')

            expect(account.connection).to receive(:get).with("/accounts/#{mock_account[:id]}", project_id: 1)
            account.show('test@example.com')
          end

          it 'request GET /roles/' do
            expect(account.connection).to receive(:get).with('/roles', project_id: 1, account_id: mock_account[:id])
            account.show('test@example.com')
          end

          it 'display record details' do
            expect(account).to receive(:output).with(mock_response)
            expect(account).to receive(:message)
            expect(account).to receive(:output).with(mock_response_role)
            account.show('test@example.com')
          end
        end
      end

      describe '#create' do
        let(:mock_response) { double(status: 201, headers: [], body: JSON.dump(mock_account)) }
        before do
          allow(account.connection).to receive(:post).with('/accounts', anything).and_return(mock_response)
        end

        it 'allow valid options' do
          allowed_options = [:email, :name, :password, :admin]
          expect(commands['create'].options.keys).to match_array(allowed_options)
        end

        it 'request POST /accounts with payload' do
          account.options = mock_account.except(:id).merge('admin' => false, 'password' => 'password', 'password_confirmation' => 'password')
          payload = account.options.merge('admin' => 0)
          expect(account.connection).to receive(:post).with('/accounts', payload)
          account.create
        end

        it 'display message and record details' do
          expect(account).to receive(:message)
          expect(account).to receive(:output).with(mock_response)
          account.create
        end

        context 'with project-role' do
          before do
            allow(account).to receive(:find_id_by).with(:project, :name, 'project_name').and_return(1)
            allow(account).to receive(:find_id_by).with(:role, :name, 'role_name', project_id: 1).and_return(1)
            account.options = mock_account.except(:id)
              .merge(admin: false,
                     password: 'password',
                     password_confirmation: 'password',
                     project: 'project_name',
                     role: 'role_name'
                  ).with_indifferent_access
          end

          it 'request POST /accounts with payload' do
            payload = account.options.except(:project, :role)
                      .merge('admin' => 0, 'project_id' => 1, 'role_id' => 1)

            expect(account.connection).to receive(:post).with('/accounts', payload)
            account.create
          end
        end
      end

      describe '#update' do
        let(:mock_response) { double(status: 200, headers: [], body: JSON.dump(mock_account)) }
        before do
          allow(account.connection).to receive(:put).with("/accounts/#{mock_account[:id]}", anything).and_return(mock_response)
        end

        it 'allow valid options' do
          allowed_options = [:email, :name, :password, :admin]
          expect(commands['update'].options.keys).to match_array(allowed_options)
        end

        it 'request PUT /accounts/:id with payload' do
          account.options = mock_account.except(:id).merge('admin' => true, 'password' => 'password', 'password_confirmation' => 'password')
          payload = account.options.merge('admin' => 1)
          expect(account.connection).to receive(:put).with("/accounts/#{mock_account[:id]}", payload)
          account.update('test@example.com')
        end

        it 'display message and record details' do
          expect(account).to receive(:message)
          expect(account).to receive(:output).with(mock_response)
          account.update('test@example.com')
        end
      end

      describe '#delete' do
        let(:mock_response) { double(status: 204, headers: [], body: JSON.dump('')) }
        before do
          allow(account.connection).to receive(:delete).with("/accounts/#{mock_account[:id]}").and_return(mock_response)
        end

        it 'allow valid options' do
          allowed_options = []
          expect(commands['delete'].options.keys).to match_array(allowed_options)
        end

        it 'request DELETE /accounts/:id' do
          expect(account.connection).to receive(:delete).with("/accounts/#{mock_account[:id]}")
          account.delete('test@example.com')
        end

        it 'display message' do
          expect(account).to receive(:message)
          account.delete('test@example.com')
        end
      end

      describe '#add_role' do
        let(:mock_response) { double(status: 201, headers: [], body: JSON.dump('')) }
        let(:mock_assignment) do
          {
            id: 1
          }
        end
        before do
          allow(account).to receive(:find_id_by).with(:project, :name, anything).and_return(1)
          allow(account).to receive(:find_id_by).with(:role, :name, anything, project_id: 1).and_return(1)
          allow(account).to receive(:find_id_by).with(:assignment, :account_id, anything, project_id: 1)
            .and_return(mock_assignment[:id])
          allow(account.connection).to receive(:post).with("/assignments/#{mock_assignment[:id]}/roles", anything).and_return(mock_response)
        end

        it 'allow valid options' do
          allowed_options = [:project, :role]
          expect(commands['add_role'].options.keys).to match_array(allowed_options)
        end

        it 'request POST /assignments/:id/roles' do
          account.options = {
            project: 'test_pj',
            role: 'test_role'
          }
          payload = {
            'role_id' => 1
          }
          expect(account.connection).to receive(:post).with("/assignments/#{mock_assignment[:id]}/roles", payload)
          account.add_role('test@example.com')
        end

        it 'display message' do
          expect(account).to receive(:message)
          expect(account).to receive(:output).with(mock_response)
          account.add_role('test@example.com')
        end
      end

      describe '#remove-role' do
        let(:mock_response) { double(status: 204, headers: [], body: JSON.dump('')) }
        let(:mock_assignment) do
          {
            id: 1
          }
        end
        let(:mock_assignment_role) do
          {
            id: 1
          }
        end
        before do
          allow(account).to receive(:find_id_by).with(:project, :name, anything).and_return(1)
          allow(account).to receive(:find_id_by).with(:role, :name, anything, project_id: 1).and_return(1)
          allow(account).to receive(:find_id_by).with(:assignment, :account_id, anything, project_id: 1)
            .and_return(mock_assignment[:id])
          allow(account).to receive(:find_id_by)
            .with(:role, :role_id, anything, parent_model: :assignment, parent_id: 1, project_id: 1)
            .and_return(mock_assignment_role[:id])
          allow(account.connection).to receive(:post).with("/assignments/#{mock_assignment[:id]}/roles", anything).and_return(mock_response)
        end

        it 'allow valid options' do
          allowed_options = [:project, :role]
          expect(commands['remove_role'].options.keys).to match_array(allowed_options)
        end

        it 'request DELETE /assignments/:id/roles/:id' do
          account.options = {
            project: 'test_pj',
            role: 'test_role'
          }
          expect(account.connection).to receive(:delete).with("/assignments/#{mock_assignment[:id]}/roles/#{mock_assignment_role[:id]}")
          account.remove_role('test@example.com')
        end

        it 'display message' do
          expect(account).to receive(:message)
          account.add_role('test@example.com')
        end
      end
    end
  end
end
