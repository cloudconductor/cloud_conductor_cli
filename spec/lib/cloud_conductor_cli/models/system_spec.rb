require 'pry'

module CloudConductorCli
  module Models
    describe System do
      before do
        @system = System.new

        @options = {}
        @system.stub(:options) { @options }
        @system.stub(:find_id_by_name).and_return(1)
        @system.stub(:error_exit).and_raise(SystemExit)
      end

      describe '#list' do
        before do
          response = double(:response, body: '{ "message": "dummy response"}', success?: true, status: 'dummy status')
          @system.stub_chain(:connection, :get).and_return(response)
          @system.stub(:display_list)
        end

        it 'display_list not call if response fail' do
          @system.stub_chain(:connection, :get).and_return(double(:response, success?: false))
          @system.should_not_receive(:display_list)

          expect { @system.list }.to raise_error(SystemExit)
        end

        it 'call connection#get' do
          @system.connection.should_receive(:get).with('/systems')

          @system.list
        end

        it 'call display_list' do
          @system.should_receive(:display_list)

          @system.list
        end
      end

      describe '#show' do
        before do
          response = double(:response, body: '{ "message": "dummy response"}', success?: true, status: 'dummy status')
          @system.stub_chain(:connection, :get).and_return(response)
          @system.stub(:display_details)
          @system_name = 'dummy_system'
        end

        it 'display_details not call if system_id nil' do
          @system.stub(:find_id_by_name).and_return(nil)
          @system.should_not_receive(:display_details)

          expect { @system.show @system_name }.to raise_error(SystemExit)
        end

        it 'display_details not call if response fail' do
          @system.stub_chain(:connection, :get).and_return(double(:response, success?: false, status: 'dummy status'))
          @system.should_not_receive(:display_details)

          expect { @system.show @system_name }.to raise_error(SystemExit)
        end

        it 'call connection#get' do
          @system.connection.should_receive(:get).with('/systems/1')

          @system.show @system_name
        end

        it 'call display_details' do
          @system.should_receive(:display_details)

          @system.show @system_name
        end
      end

      describe '#create' do
        before do
          response = double(:response, body: '{ "message": "dummy response"}', success?: true, status: 'dummy status')
          @system.stub_chain(:connection, :post).and_return(response)
          @system.stub(:clouds_with_priority).and_return([])
          @system.stub(:stacks).and_return([])
          @system.stub(:display_message)
          @system.stub(:display_details)
          @options = { 'name' => 'dummy_name', 'domain' => 'dummy_domain', 'patterns' => [], 'clouds' => [] }
        end

        it 'display_details not call if response fail' do
          @system.stub_chain(:connection, :post).and_return(double(:response, success?: false, status: 'dummy status'))
          @system.should_not_receive(:display_details)

          expect { @system.create }.to raise_error(SystemExit)
        end

        it 'call connection#post' do
          payload = { name: 'dummy_name', domain: 'dummy_domain', clouds: [], stacks: [] }
          @system.connection.should_receive(:post).with('/systems', payload)

          @system.create
        end

        it 'call display_details' do
          @system.should_receive(:display_details)

          @system.create
        end
      end

      describe '#update' do
        before do
          response = double(:response, body: '{ "message": "dummy response"}', success?: true, status: 'dummy status')
          @system.stub_chain(:connection, :put).and_return(response)
          @system.stub(:display_message)
          @system.stub(:display_details)
          @options = { 'patterns' => [] }
        end

        it 'display_details not call if system_id nil' do
          @system.stub(:find_id_by_name).and_return(nil)
          @system.should_not_receive(:display_details)

          expect { @system.update @system_name }.to raise_error(SystemExit)
        end

        it 'display_details not call if response fail' do
          @system.stub_chain(:connection, :put).and_return(double(:response, success?: false, status: 'dummy status'))
          @system.should_not_receive(:display_details)

          expect { @system.update @system_name }.to raise_error(SystemExit)
        end

        it 'call connection#put' do
          @system.connection.should_receive(:put).with('/systems/1', {})

          @system.update @system_name
        end

        it 'call display_details' do
          @system.should_receive(:display_details)

          @system.update @system_name
        end
      end

      describe '#delete' do
        before do
          response = double(:response, body: '{ "message": "dummy response"}', success?: true, status: 'dummy status')
          @system.stub_chain(:connection, :delete).and_return(response)
          @system.stub(:display_message)
        end

        it 'display_message not call if system_id nil' do
          @system.stub(:find_id_by_name).and_return(nil)
          @system.should_not_receive(:display_message)

          expect { @system.delete @system_name }.to raise_error(SystemExit)
        end

        it 'display_message not call if response fail' do
          @system.stub_chain(:connection, :delete).and_return(double(:response, success?: false, status: 'dummy status'))
          @system.should_not_receive(:display_message)

          expect { @system.delete @system_name }.to raise_error(SystemExit)
        end

        it 'call connection#delete' do
          @system.connection.should_receive(:delete).with('/systems/1')

          @system.delete @system_name
        end

        it 'call display_details' do
          @system.should_receive(:display_message)

          @system.delete @system_name
        end
      end
    end
  end
end
