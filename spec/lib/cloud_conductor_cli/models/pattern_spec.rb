module CloudConductorCli
  module Models
    describe Pattern do
      before do
        @pattern = Pattern.new

        @options = {}
        allow(@pattern).to receive(:options) { @options }
        allow(@pattern).to receive(:find_id_by_name).and_return(1)
        allow(@pattern).to receive(:error_exit).and_raise(SystemExit)
      end

      describe '#list' do
        before do
          response = double(:response, body: '{ "message": "dummy response"}', success?: true, status: 'dummy status')
          allow(@pattern).to receive_message_chain(:connection, :get).and_return(response)
          allow(@pattern).to receive(:display_list)
        end

        it 'display_list not call if response fail' do
          allow(@pattern).to receive_message_chain(:connection, :get).and_return(double(:response, success?: false))
          expect(@pattern).not_to receive(:display_list)

          expect { @pattern.list }.to raise_error(SystemExit)
        end

        it 'call connection#get' do
          expect(@pattern.connection).to receive(:get).with('/patterns')

          @pattern.list
        end

        it 'call display_list' do
          expect(@pattern).to receive(:display_list)

          @pattern.list
        end
      end

      describe '#show' do
        before do
          response = double(:response, body: '{ "message": "dummy response"}', success?: true, status: 'dummy status')
          allow(@pattern).to receive_message_chain(:connection, :get).and_return(response)
          allow(@pattern).to receive(:display_details)
          @pattern_name = 'dummy_pattern'
        end

        it 'display_details not call if pattern_id nil' do
          allow(@pattern).to receive(:find_id_by_name).and_return(nil)
          expect(@pattern).not_to receive(:display_details)

          expect { @pattern.show @pattern_name }.to raise_error(SystemExit)
        end

        it 'display_details not call if response fail' do
          allow(@pattern).to receive_message_chain(:connection, :get).and_return(double(:response, success?: false, status: 'dummy status'))
          expect(@pattern).not_to receive(:display_details)

          expect { @pattern.show @pattern_name }.to raise_error(SystemExit)
        end

        it 'call connection#get' do
          expect(@pattern.connection).to receive(:get).with('/patterns/1')

          @pattern.show @pattern_name
        end

        it 'call display_details' do
          expect(@pattern).to receive(:display_details)

          @pattern.show @pattern_name
        end
      end

      describe '#show_parameters' do
        before do
          response = double(:response, body: '{ "message": "dummy response"}', success?: true, status: 'dummy status')
          allow(@pattern).to receive_message_chain(:connection, :get).and_return(response)
          allow(@pattern).to receive(:display_details)
          @pattern_name = 'dummy_pattern'
        end

        it 'display_details not call if pattern_id nil' do
          allow(@pattern).to receive(:find_id_by_name).and_return(nil)
          expect(@pattern).not_to receive(:display_details)

          expect { @pattern.show_parameters @pattern_name }.to raise_error(SystemExit)
        end

        it 'display_details not call if response fail' do
          allow(@pattern).to receive_message_chain(:connection, :get).and_return(double(:response, success?: false, status: 'dummy status'))
          expect(@pattern).not_to receive(:display_details)

          expect { @pattern.show_parameters @pattern_name }.to raise_error(SystemExit)
        end

        it 'call connection#get' do
          expect(@pattern.connection).to receive(:get).with('/patterns/1/parameters')

          @pattern.show_parameters @pattern_name
        end

        it 'call display_details' do
          expect(@pattern).to receive(:display_details)

          @pattern.show_parameters @pattern_name
        end
      end

      describe '#create' do
        before do
          response = double(:response, body: '{ "message": "dummy response"}', success?: true, status: 'dummy status')
          allow(@pattern).to receive_message_chain(:connection, :post).and_return(response)
          allow(@pattern).to receive(:display_message)
          allow(@pattern).to receive(:display_details)
          @options = { 'url' => 'http://example.com/dummy', 'revision' => 'master' }
        end

        it 'filter payload' do
          @options['unnecessary_key'] = 'Unnecessary Value'
          expect(@pattern.connection).to receive(:post).with('/patterns', hash_excluding('unnecessary_key'))

          @pattern.create
        end

        it 'display_details not call if response fail' do
          allow(@pattern).to receive_message_chain(:connection, :post).and_return(double(:response, success?: false, status: 'dummy status'))
          expect(@pattern).not_to receive(:display_details)

          expect { @pattern.create }.to raise_error(SystemExit)
        end

        it 'call connection#post' do
          payload = { url: 'http://example.com/dummy', revision: 'master' }
          expect(@pattern.connection).to receive(:post).with('/patterns', payload)

          @pattern.create
        end

        it 'call display_details' do
          expect(@pattern).to receive(:display_details)

          @pattern.create
        end
      end

      describe '#update' do
        before do
          response = double(:response, body: '{ "message": "dummy response"}', success?: true, status: 'dummy status')
          allow(@pattern).to receive_message_chain(:connection, :put).and_return(response)
          allow(@pattern).to receive(:display_message)
          allow(@pattern).to receive(:display_details)
          @pattern_name = 'dummy_pattern'
          @options = { 'url' => 'http://example.com/dummy', 'revision' => 'master' }
        end

        it 'display_details not call if system_id nil' do
          allow(@pattern).to receive(:find_id_by_name).and_return(nil)
          expect(@pattern).not_to receive(:display_details)

          expect { @pattern.update @pattern_name }.to raise_error(SystemExit)
        end

        it 'filter payload' do
          @options['unnecessary_key'] = 'Unnecessary Value'
          expect(@pattern.connection).to receive(:put).with('/patterns/1', hash_excluding('unnecessary_key'))

          @pattern.update @pattern_name
        end

        it 'display_details not call if response fail' do
          allow(@pattern).to receive_message_chain(:connection, :put).and_return(double(:response, success?: false, status: 'dummy status'))
          expect(@pattern).not_to receive(:display_details)

          expect { @pattern.update @pattern_name }.to raise_error(SystemExit)
        end

        it 'call connection#put' do
          payload = { url: 'http://example.com/dummy', revision: 'master' }
          expect(@pattern.connection).to receive(:put).with('/patterns/1', payload)

          @pattern.update @pattern_name
        end

        it 'call display_details' do
          expect(@pattern).to receive(:display_details)

          @pattern.update @pattern_name
        end
      end

      describe '#delete' do
        before do
          response = double(:response, body: '{ "message": "dummy response"}', success?: true, status: 'dummy status')
          allow(@pattern).to receive_message_chain(:connection, :delete).and_return(response)
          allow(@pattern).to receive(:display_message)
          @pattern_name = 'dummy_pattern'
        end

        it 'display_message not call if pattern_id nil' do
          allow(@pattern).to receive(:find_id_by_name).and_return(nil)
          expect(@pattern).not_to receive(:display_message)

          expect { @pattern.delete @pattern_name }.to raise_error(SystemExit)
        end

        it 'display_message not call if response fail' do
          allow(@pattern).to receive_message_chain(:connection, :delete).and_return(double(:response, success?: false, status: 'dummy status'))
          expect(@pattern).not_to receive(:display_message)

          expect { @pattern.delete @pattern_name }.to raise_error(SystemExit)
        end

        it 'call connection#delete' do
          expect(@pattern.connection).to receive(:delete).with('/patterns/1')

          @pattern.delete @pattern_name
        end

        it 'call display_details' do
          expect(@pattern).to receive(:display_message)

          @pattern.delete @pattern_name
        end
      end
    end
  end
end
