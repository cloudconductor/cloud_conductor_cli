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
        allow(account).to receive(:display_message)
        allow(account).to receive(:display_list)
        allow(account).to receive(:display_details)
      end

      describe '#list' do
        let(:mock_response) { double(status: 200, headers: [], body: JSON.dump([mock_account])) }
        before do
          allow(account.connection).to receive(:get).with('/accounts').and_return(mock_response)
        end

        it 'allow valid options' do
          allowed_options = []
          expect(commands['list'].options.keys).to match_array(allowed_options)
        end

        it 'request GET /accounts' do
          expect(account.connection).to receive(:get).with('/accounts')
          account.list
        end

        it 'display record list' do
          expect(account).to receive(:display_list).with([mock_account.stringify_keys])
          account.list
        end
      end

      describe '#show' do
        let(:mock_response) { double(status: 200, headers: [], body: JSON.dump(mock_account)) }
        before do
          allow(account.connection).to receive(:get).with("/accounts/#{mock_account[:id]}").and_return(mock_response)
        end

        it 'allow valid options' do
          allowed_options = []
          expect(commands['show'].options.keys).to match_array(allowed_options)
        end

        it 'request GET /accounts/:id' do
          expect(account.connection).to receive(:get).with("/accounts/#{mock_account[:id]}")
          account.show('test@example.com')
        end

        it 'display record details' do
          expect(account).to receive(:display_details).with(mock_account.stringify_keys)
          account.show('test@example.com')
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
          expect(account).to receive(:display_message)
          expect(account).to receive(:display_details).with(mock_account.stringify_keys)
          account.create
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
          expect(account).to receive(:display_message)
          expect(account).to receive(:display_details).with(mock_account.stringify_keys)
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
          expect(account).to receive(:display_message)
          account.delete('test@example.com')
        end
      end
    end
  end
end
