module CloudConductorCli
  module Models
    describe System do
      before do
        @system = System.new

        @options = {}
        allow(@system).to receive(:options) { @options }
        allow(@system).to receive(:find_id_by_name).and_return(1)
        allow(@system).to receive(:error_exit).and_raise(SystemExit)
      end

      describe '#list' do
        before do
          response = double(:response, body: '{ "message": "dummy response"}', success?: true, status: 'dummy status')
          allow(@system).to receive_message_chain(:connection, :get).and_return(response)
          allow(@system).to receive(:display_list)
        end

        it 'display_list not call if response fail' do
          allow(@system).to receive_message_chain(:connection, :get).and_return(double(:response, success?: false))
          expect(@system).not_to receive(:display_list)

          expect { @system.list }.to raise_error(SystemExit)
        end

        it 'call connection#get' do
          expect(@system.connection).to receive(:get).with('/systems')

          @system.list
        end

        it 'call display_list' do
          expect(@system).to receive(:display_list)

          @system.list
        end
      end

      describe '#show' do
        before do
          response = double(:response, body: '{ "message": "dummy response"}', success?: true, status: 'dummy status')
          allow(@system).to receive_message_chain(:connection, :get).and_return(response)
          allow(@system).to receive(:display_details)
          @system_name = 'dummy_system'
        end

        it 'display_details not call if system_id nil' do
          allow(@system).to receive(:find_id_by_name).and_return(nil)
          expect(@system).not_to receive(:display_details)

          expect { @system.show @system_name }.to raise_error(SystemExit)
        end

        it 'display_details not call if response fail' do
          allow(@system).to receive_message_chain(:connection, :get).and_return(double(:response, success?: false, status: 'dummy status'))
          expect(@system).not_to receive(:display_details)

          expect { @system.show @system_name }.to raise_error(SystemExit)
        end

        it 'call connection#get' do
          expect(@system.connection).to receive(:get).with('/systems/1')

          @system.show @system_name
        end

        it 'call display_details' do
          expect(@system).to receive(:display_details)

          @system.show @system_name
        end
      end

      describe '#create' do
        before do
          response = double(:response, body: '{ "message": "dummy response"}', success?: true, status: 'dummy status')
          allow(@system).to receive_message_chain(:connection, :post).and_return(response)
          allow(@system).to receive(:clouds_with_priority).and_return([])
          allow(@system).to receive(:stacks).and_return([])
          allow(@system).to receive(:display_message)
          allow(@system).to receive(:display_details)
          @options = { 'name' => 'dummy_name', 'domain' => 'dummy_domain', 'patterns' => [], 'clouds' => [] }
        end

        it 'display_details not call if response fail' do
          allow(@system).to receive_message_chain(:connection, :post).and_return(double(:response, success?: false, status: 'dummy status'))
          expect(@system).not_to receive(:display_details)

          expect { @system.create }.to raise_error(SystemExit)
        end

        it 'call connection#post' do
          payload = { name: 'dummy_name', domain: 'dummy_domain', clouds: [], stacks: [] }
          expect(@system.connection).to receive(:post).with('/systems', payload)

          @system.create
        end

        it 'call display_details' do
          expect(@system).to receive(:display_details)

          @system.create
        end
      end

      describe '#update' do
        before do
          response = double(:response, body: '{ "message": "dummy response"}', success?: true, status: 'dummy status')
          allow(@system).to receive_message_chain(:connection, :put).and_return(response)
          allow(@system).to receive(:display_message)
          allow(@system).to receive(:display_details)
          @options = { 'patterns' => [] }
        end

        it 'display_details not call if system_id nil' do
          allow(@system).to receive(:find_id_by_name).and_return(nil)
          expect(@system).not_to receive(:display_details)

          expect { @system.update @system_name }.to raise_error(SystemExit)
        end

        it 'display_details not call if response fail' do
          allow(@system).to receive_message_chain(:connection, :put).and_return(double(:response, success?: false, status: 'dummy status'))
          expect(@system).not_to receive(:display_details)

          expect { @system.update @system_name }.to raise_error(SystemExit)
        end

        it 'call connection#put' do
          expect(@system.connection).to receive(:put).with('/systems/1', {})

          @system.update @system_name
        end

        it 'call display_details' do
          expect(@system).to receive(:display_details)

          @system.update @system_name
        end
      end

      describe '#delete' do
        before do
          response = double(:response, body: '{ "message": "dummy response"}', success?: true, status: 'dummy status')
          allow(@system).to receive_message_chain(:connection, :delete).and_return(response)
          allow(@system).to receive(:display_message)
        end

        it 'display_message not call if system_id nil' do
          allow(@system).to receive(:find_id_by_name).and_return(nil)
          expect(@system).not_to receive(:display_message)

          expect { @system.delete @system_name }.to raise_error(SystemExit)
        end

        it 'display_message not call if response fail' do
          allow(@system).to receive_message_chain(:connection, :delete).and_return(double(:response, success?: false, status: 'dummy status'))
          expect(@system).not_to receive(:display_message)

          expect { @system.delete @system_name }.to raise_error(SystemExit)
        end

        it 'call connection#delete' do
          expect(@system.connection).to receive(:delete).with('/systems/1')

          @system.delete @system_name
        end

        it 'call display_details' do
          expect(@system).to receive(:display_message)

          @system.delete @system_name
        end
      end
    end
  end
end
