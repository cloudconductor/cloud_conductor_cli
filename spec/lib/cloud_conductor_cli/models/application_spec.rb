module CloudConductorCli
  module Models
    describe Application do
      before do
        @application = Application.new

        @options = {}
        allow(@application).to receive(:options) { @options }
        allow(@application).to receive(:find_id_by_name).and_return(1)
        allow(@application).to receive(:find_id_by_name).with(:application, 'dummy_application', anything).and_return(2)
        allow(@application).to receive(:error_exit).and_raise(SystemExit)
      end

      describe '#list' do
        before do
          response = double(:response, body: '{ "message": "dummy response"}', success?: true, status: 'dummy status')
          allow(@application).to receive_message_chain(:connection, :get).and_return(response)
          allow(@application).to receive(:display_list)
          @options = { 'system_name' => 'dummy_name' }
        end

        it 'display_list not call if system_id nil' do
          allow(@application).to receive(:find_id_by_name).and_return(nil)
          expect(@application).not_to receive(:display_list)

          expect { @application.list }.to raise_error(SystemExit)
        end

        it 'display_list not call if response fail' do
          allow(@application).to receive_message_chain(:connection, :get).and_return(double(:response, success?: false, body: ''))
          expect(@application).not_to receive(:display_list)

          expect { @application.list }.to raise_error(SystemExit)
        end

        it 'call connection#get to get application list' do
          expect(@application.connection).to receive(:get).with('/systems/1/applications')

          @application.list
        end

        it 'call display_list' do
          expect(@application).to receive(:display_list)

          @application.list
        end
      end

      describe '#show' do
        before do
          response = double(:response, body: '{ "message": "dummy response"}', success?: true, status: 'dummy status')
          allow(@application).to receive_message_chain(:connection, :get).and_return(response)
          allow(@application).to receive(:display_details)
          @options = { 'system_name' => 'dummy_name' }
          @application_name = 'dummy_application'
        end

        it 'display_details not call if system_id nil' do
          allow(@application).to receive(:find_id_by_name).and_return(nil)
          expect(@application).not_to receive(:display_details)

          expect { @application.show @application_name }.to raise_error(SystemExit)
        end

        it 'display_details not call if application_id nil' do
          allow(@application).to receive(:find_id_by_name).with(:application, 'dummy_application', anything).and_return(nil)
          expect(@application).not_to receive(:display_details)

          expect { @application.show @application_name }.to raise_error(SystemExit)
        end

        it 'display_details not call if response fail' do
          response = double(:response, success?: false, body: '', status: 'dummy_error')
          allow(@application).to receive_message_chain(:connection, :get).and_return(response)
          expect(@application).not_to receive(:display_details)

          expect { @application.show @application_name }.to raise_error(SystemExit)
        end

        it 'call connection#get' do
          expect(@application.connection).to receive(:get).with('/systems/1/applications/2')

          @application.show @application_name
        end

        it 'call display_details' do
          expect(@application).to receive(:display_details)

          @application.show @application_name
        end
      end

      describe '#create' do
        before do
          response = double(:response, body: '{ "message": "dummy response"}', success?: true, status: 'dummy status')
          allow(@application).to receive_message_chain(:connection, :post).and_return(response)
          allow(@application).to receive(:display_message)
          allow(@application).to receive(:display_details)
          @options = { 'system_name' => 'dummy_name', 'name' => 'dummy_name', 'domain' => 'dummy_domain' }
          @application_name = 'dummy_application'
        end

        it 'display_details not call if system_id nil' do
          allow(@application).to receive(:find_id_by_name).and_return(nil)
          expect(@application).not_to receive(:display_details)

          expect { @application.create }.to raise_error(SystemExit)
        end

        it 'filter payload' do
          @options['unnecessary_key'] = 'Unnecessary Value'
          expect(@application.connection).to receive(:post).with('/systems/1/applications', hash_excluding('unnecessary_key'))

          @application.create
        end

        it 'display_details not call if response fail' do
          response = double(:response, success?: false, body: '', status: 'dummy_error')
          allow(@application).to receive_message_chain(:connection, :post).and_return(response)
          expect(@application).not_to receive(:display_details)

          expect { @application.create }.to raise_error(SystemExit)
        end

        it 'call connection#post' do
          payload = { 'name' => 'dummy_name', 'domain' => 'dummy_domain' }
          expect(@application.connection).to receive(:post).with('/systems/1/applications', payload)

          @application.create
        end

        it 'call display_details' do
          expect(@application).to receive(:display_details)

          @application.create
        end
      end

      describe '#update' do
        before do
          response = double(:response, body: '{ "message": "dummy response"}', success?: true, status: 'dummy status')
          allow(@application).to receive_message_chain(:connection, :put).and_return(response)
          allow(@application).to receive(:display_message)
          allow(@application).to receive(:display_details)
          @options = { 'system_name' => 'dummy_name' }
          @application_name = 'dummy_application'
        end

        it 'display_details not call if system_id nil' do
          allow(@application).to receive(:find_id_by_name).and_return(nil)
          expect(@application).not_to receive(:display_details)

          expect { @application.update @application_name }.to raise_error(SystemExit)
        end

        it 'display_details not call if application_id nil' do
          allow(@application).to receive(:find_id_by_name).with(:application, 'dummy_application', anything).and_return(nil)
          expect(@application).not_to receive(:display_details)

          expect { @application.update @application_name }.to raise_error(SystemExit)
        end

        it 'filter payload' do
          @options['unnecessary_key'] = 'Unnecessary Value'
          expect(@application.connection).to receive(:put).with('/systems/1/applications/2', hash_excluding('unnecessary_key'))

          @application.update @application_name
        end

        it 'display_details not call if response fail' do
          response = double(:response, success?: false, body: '', status: 'dummy_error')
          allow(@application).to receive_message_chain(:connection, :put).and_return(response)
          expect(@application).not_to receive(:display_details)

          expect { @application.update @application_name }.to raise_error(SystemExit)
        end

        it 'call connection#put' do
          expect(@application.connection).to receive(:put).with('/systems/1/applications/2', anything)

          @application.update @application_name
        end

        it 'call display_details' do
          expect(@application).to receive(:display_details)

          @application.update @application_name
        end
      end

      describe '#delete' do
        before do
          response = double(:response, body: '{ "message": "dummy response"}', success?: true, status: 'dummy status')
          allow(@application).to receive_message_chain(:connection, :delete).and_return(response)
          allow(@application).to receive(:display_message)
          @application_name = 'dummy_application'
          @options = { 'system_name' => 'dummy_name' }
        end

        it 'display_message not call if system_id nil' do
          allow(@application).to receive(:find_id_by_name).and_return(nil)
          expect(@application).not_to receive(:display_message)

          expect { @application.delete @application_name }.to raise_error(SystemExit)
        end

        it 'display_message not call if application_id nil' do
          allow(@application).to receive(:find_id_by_name).with(:application, 'dummy_application', anything).and_return(nil)
          expect(@application).not_to receive(:display_message)

          expect { @application.delete @application_name }.to raise_error(SystemExit)
        end

        it 'display_message not call if response fail' do
          response = double(:response, success?: false, body: '', status: 'dummy_error')
          allow(@application).to receive_message_chain(:connection, :delete).and_return(response)
          expect(@application).not_to receive(:display_message)

          expect { @application.delete @application_name }.to raise_error(SystemExit)
        end

        it 'call connection#delete' do
          expect(@application.connection).to receive(:delete).with('/systems/1/applications/2')

          @application.delete @application_name
        end

        it 'call display_message' do
          expect(@application).to receive(:display_message)

          @application.delete @application_name
        end
      end
    end
  end
end
