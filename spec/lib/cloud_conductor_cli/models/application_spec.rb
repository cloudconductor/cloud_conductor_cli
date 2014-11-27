module CloudConductorCli
  module Models
    describe Application do
      before do
        @application = Application.new

        @options = {}
        @application.stub(:options) { @options }
        @application.stub(:find_id_by_name).and_return(1)
        @application.stub(:find_id_by_name).with(:application, 'dummy_application', anything).and_return(2)
        @application.stub(:error_exit).and_raise(SystemExit)
      end

      describe '#list' do
        before do
          response = double(:response, body: '{ "message": "dummy response"}', success?: true, status: 'dummy status')
          @application.stub_chain(:connection, :get).and_return(response)
          @application.stub(:display_list)
          @options = { 'system_name' => 'dummy_name' }
        end

        it 'display_list not call if system_id nil' do
          @application.stub(:find_id_by_name).and_return(nil)
          @application.should_not_receive(:display_list)

          expect { @application.list }.to raise_error(SystemExit)
        end

        it 'display_list not call if response fail' do
          @application.stub_chain(:connection, :get).and_return(double(:response, success?: false, body: ''))
          @application.should_not_receive(:display_list)

          expect { @application.list }.to raise_error(SystemExit)
        end

        it 'call connection#get to get application list' do
          @application.connection.should_receive(:get).with('/systems/1/applications')

          @application.list
        end

        it 'call display_list' do
          @application.should_receive(:display_list)

          @application.list
        end
      end

      describe '#show' do
        before do
          response = double(:response, body: '{ "message": "dummy response"}', success?: true, status: 'dummy status')
          @application.stub_chain(:connection, :get).and_return(response)
          @application.stub(:display_details)
          @options = { 'system_name' => 'dummy_name' }
          @application_name = 'dummy_application'
        end

        it 'display_details not call if system_id nil' do
          @application.stub(:find_id_by_name).and_return(nil)
          @application.should_not_receive(:display_details)

          expect { @application.show @application_name }.to raise_error(SystemExit)
        end

        it 'display_details not call if application_id nil' do
          @application.stub(:find_id_by_name).with(:application, 'dummy_application', anything).and_return(nil)
          @application.should_not_receive(:display_details)

          expect { @application.show @application_name }.to raise_error(SystemExit)
        end

        it 'display_details not call if response fail' do
          response = double(:response, success?: false, body: '', status: 'dummy_error')
          @application.stub_chain(:connection, :get).and_return(response)
          @application.should_not_receive(:display_details)

          expect { @application.show @application_name }.to raise_error(SystemExit)
        end

        it 'call connection#get' do
          @application.connection.should_receive(:get).with('/systems/1/applications/2')

          @application.show @application_name
        end

        it 'call display_details' do
          @application.should_receive(:display_details)

          @application.show @application_name
        end
      end

      describe '#create' do
        before do
          response = double(:response, body: '{ "message": "dummy response"}', success?: true, status: 'dummy status')
          @application.stub_chain(:connection, :post).and_return(response)
          @application.stub(:display_message)
          @application.stub(:display_details)
          @options = { 'system_name' => 'dummy_name', 'name' => 'dummy_name', 'domain' => 'dummy_domain' }
          @application_name = 'dummy_application'
        end

        it 'display_details not call if system_id nil' do
          @application.stub(:find_id_by_name).and_return(nil)
          @application.should_not_receive(:display_details)

          expect { @application.create }.to raise_error(SystemExit)
        end

        it 'filter payload' do
          @options['unnecessary_key'] = 'Unnecessary Value'
          @application.connection.should_receive(:post).with('/systems/1/applications', hash_excluding('unnecessary_key'))

          @application.create
        end

        it 'display_details not call if response fail' do
          response = double(:response, success?: false, body: '', status: 'dummy_error')
          @application.stub_chain(:connection, :post).and_return(response)
          @application.should_not_receive(:display_details)

          expect { @application.create }.to raise_error(SystemExit)
        end

        it 'call connection#post' do
          payload = { 'name' => 'dummy_name', 'domain' => 'dummy_domain' }
          @application.connection.should_receive(:post).with('/systems/1/applications', payload)

          @application.create
        end

        it 'call display_details' do
          @application.should_receive(:display_details)

          @application.create
        end
      end

      describe '#update' do
        before do
          response = double(:response, body: '{ "message": "dummy response"}', success?: true, status: 'dummy status')
          @application.stub_chain(:connection, :put).and_return(response)
          @application.stub(:display_message)
          @application.stub(:display_details)
          @options = { 'system_name' => 'dummy_name' }
          @application_name = 'dummy_application'
        end

        it 'display_details not call if system_id nil' do
          @application.stub(:find_id_by_name).and_return(nil)
          @application.should_not_receive(:display_details)

          expect { @application.update @application_name }.to raise_error(SystemExit)
        end

        it 'display_details not call if application_id nil' do
          @application.stub(:find_id_by_name).with(:application, 'dummy_application', anything).and_return(nil)
          @application.should_not_receive(:display_details)

          expect { @application.update @application_name }.to raise_error(SystemExit)
        end

        it 'filter payload' do
          @options['unnecessary_key'] = 'Unnecessary Value'
          @application.connection.should_receive(:put).with('/systems/1/applications/2', hash_excluding('unnecessary_key'))

          @application.update @application_name
        end

        it 'display_details not call if response fail' do
          response = double(:response, success?: false, body: '', status: 'dummy_error')
          @application.stub_chain(:connection, :put).and_return(response)
          @application.should_not_receive(:display_details)

          expect { @application.update @application_name }.to raise_error(SystemExit)
        end

        it 'call connection#put' do
          @application.connection.should_receive(:put).with('/systems/1/applications/2', anything)

          @application.update @application_name
        end

        it 'call display_details' do
          @application.should_receive(:display_details)

          @application.update @application_name
        end
      end

      describe '#delete' do
        before do
          response = double(:response, body: '{ "message": "dummy response"}', success?: true, status: 'dummy status')
          @application.stub_chain(:connection, :delete).and_return(response)
          @application.stub(:display_message)
          @application_name = 'dummy_application'
          @options = { 'system_name' => 'dummy_name' }
        end

        it 'display_message not call if system_id nil' do
          @application.stub(:find_id_by_name).and_return(nil)
          @application.should_not_receive(:display_message)

          expect { @application.delete @application_name }.to raise_error(SystemExit)
        end

        it 'display_message not call if application_id nil' do
          @application.stub(:find_id_by_name).with(:application, 'dummy_application', anything).and_return(nil)
          @application.should_not_receive(:display_message)

          expect { @application.delete @application_name }.to raise_error(SystemExit)
        end

        it 'display_message not call if response fail' do
          response = double(:response, success?: false, body: '', status: 'dummy_error')
          @application.stub_chain(:connection, :delete).and_return(response)
          @application.should_not_receive(:display_message)

          expect { @application.delete @application_name }.to raise_error(SystemExit)
        end

        it 'call connection#delete' do
          @application.connection.should_receive(:delete).with('/systems/1/applications/2')

          @application.delete @application_name
        end

        it 'call display_message' do
          @application.should_receive(:display_message)

          @application.delete @application_name
        end
      end
    end
  end
end
