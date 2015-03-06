require 'active_support/core_ext'

module CloudConductorCli
  module Models
    describe Application do
      let(:application) { CloudConductorCli::Models::Application.new }
      let(:commands) { CloudConductorCli::Models::Application.commands }
      let(:mock_application) do
        {
          id: 1,
          system_id: 1,
          name: 'application_name',
          description: 'application_description'
        }
      end
      let(:mock_application_history) do
        {
          id: 1,
          application_id: 1,
          version: '20150123-001',
          domain: 'sample-app.example.com',
          type: 'dynamic',
          protocol: 'git',
          url: 'http://example.com/repo.git',
          revision: 'master',
          pre_deploy: '',
          post_deploy: '',
          parameters: '{}'
        }
      end

      before do
        allow(CloudConductorCli::Helpers::Connection).to receive(:new).and_return(double(get: true, post: true, put: true, delete: true, request: true))
        allow(application).to receive(:find_id_by).with(:application, :name, anything).and_return(mock_application[:id])
        allow(application).to receive(:find_id_by).with(:history, :version, any_args).and_return(mock_application_history[:id])
        allow(application).to receive(:find_id_by).with(:system, :name, anything).and_return(1)
        allow(application).to receive(:display_message)
        allow(application).to receive(:display_list)
        allow(application).to receive(:display_details)
      end

      describe '#list' do
        let(:mock_response) { double(status: 200, headers: [], body: JSON.dump([mock_application])) }
        before do
          allow(application.connection).to receive(:get).with('/applications').and_return(mock_response)
        end

        it 'allow valid options' do
          allowed_options = []
          expect(commands['list'].options.keys).to match_array(allowed_options)
        end

        it 'request GET /applications' do
          expect(application.connection).to receive(:get).with('/applications')
          application.list
        end

        it 'display record list' do
          expect(application).to receive(:display_list).with([mock_application.stringify_keys])
          application.list
        end
      end

      describe '#show' do
        let(:mock_response) { double(status: 200, headers: [], body: JSON.dump(mock_application)) }
        let(:mock_response_history) { double(status: 200, headers: [], body: JSON.dump(mock_application_history)) }
        let(:mock_response_histories) { double(status: 200, headers: [], body: JSON.dump([mock_application_history])) }
        before do
          allow(application.connection).to receive(:get).with("/applications/#{mock_application[:id]}").and_return(mock_response)
          allow(application.connection).to receive(:get).with("/applications/#{mock_application[:id]}/histories")
            .and_return(mock_response_histories)
          allow(application.connection).to receive(:get).with("/applications/#{mock_application[:id]}/histories/#{mock_application_history[:id]}")
            .and_return(mock_response_history)
        end

        it 'allow valid options' do
          allowed_options = [:version]
          expect(commands['show'].options.keys).to match_array(allowed_options)
        end

        context 'without version' do
          it 'request GET /applications/:id and GET /applications/:id/histories' do
            expect(application.connection).to receive(:get).with("/applications/#{mock_application[:id]}")
            expect(application.connection).to receive(:get).with("/applications/#{mock_application[:id]}/histories")
            application.show('application_name')
          end

          it 'display record details' do
            expect(application).to receive(:display_details).with(mock_application.stringify_keys).ordered
            expect(application).to receive(:display_list).with([mock_application_history.stringify_keys])
            application.show('application_name')
          end
        end

        context 'with version' do
          before { application.options = { version: mock_application_history[:version] } }

          it 'request GET /applications/:id and GET /applications/:id/histories/:id' do
            expect(application.connection).to receive(:get).with("/applications/#{mock_application[:id]}")
            expect(application.connection).to receive(:get).with("/applications/#{mock_application[:id]}/histories/#{mock_application_history[:id]}")
            application.show('application_name')
          end

          it 'display record details' do
            expect(application).to receive(:display_details).with(mock_application.stringify_keys)
            expect(application).to receive(:display_details).with(mock_application_history.stringify_keys)
            application.show('application_name')
          end
        end
      end

      describe '#create' do
        let(:mock_response) { double(status: 201, headers: [], body: JSON.dump(mock_application)) }
        before do
          allow(application.connection).to receive(:post).with('/applications', anything).and_return(mock_response)
        end

        it 'allow valid options' do
          allowed_options = [:system, :name, :description]
          expect(commands['create'].options.keys).to match_array(allowed_options)
        end

        it 'request POST /applications with payload' do
          application.options = mock_application.except(:id, :system_id).merge('system' => 'system_name')
          payload = application.options.except('system').merge('system_id' => 1)
          expect(application.connection).to receive(:post).with('/applications', payload)
          application.create
        end

        it 'display message and record details' do
          expect(application).to receive(:display_message)
          expect(application).to receive(:display_details).with(mock_application.stringify_keys)
          application.create
        end
      end

      describe '#update' do
        let(:mock_response) { double(status: 200, headers: [], body: JSON.dump(mock_application)) }
        before do
          allow(application.connection).to receive(:put).with("/applications/#{mock_application[:id]}", anything).and_return(mock_response)
        end

        it 'allow valid options' do
          allowed_options = [:name, :description]
          expect(commands['update'].options.keys).to match_array(allowed_options)
        end

        it 'request PUT /applications/:id with payload' do
          application.options = mock_application.except(:id, :system_id)
          payload = application.options
          expect(application.connection).to receive(:put).with("/applications/#{mock_application[:id]}", payload)
          application.update('application_name')
        end

        it 'display message and record details' do
          expect(application).to receive(:display_message)
          expect(application).to receive(:display_details).with(mock_application.stringify_keys)
          application.update('application_name')
        end
      end

      describe '#delete' do
        let(:mock_response) { double(status: 204, headers: [], body: JSON.dump('')) }
        before do
          allow(application.connection).to receive(:delete).with("/applications/#{mock_application[:id]}").and_return(mock_response)
        end

        it 'allow valid options' do
          allowed_options = []
          expect(commands['delete'].options.keys).to match_array(allowed_options)
        end

        it 'request DELETE /applications/:id' do
          expect(application.connection).to receive(:delete).with("/applications/#{mock_application[:id]}")
          application.delete('application_name')
        end

        it 'display message' do
          expect(application).to receive(:display_message)
          application.delete('application_name')
        end
      end
    end
  end
end
