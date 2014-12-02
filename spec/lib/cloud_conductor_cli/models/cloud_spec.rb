module CloudConductorCli
  module Models
    describe Cloud do
      before do
        @cloud = Cloud.new

        @options = {}
        @cloud.stub(:options) { @options }
        @cloud.stub(:find_id_by_name).and_return(1)
        @cloud.stub(:error_exit).and_raise(SystemExit)
      end

      describe '#list' do
        before do
          response = double(:response, body: '{ "message": "dummy response"}', success?: true, status: 'dummy status')
          @cloud.stub_chain(:connection, :get).and_return(response)
          @cloud.stub(:display_list)
        end

        it 'display_list not call if response fail' do
          @cloud.stub_chain(:connection, :get).and_return(double(:response, success?: false))
          @cloud.should_not_receive(:display_list)

          expect { @cloud.list }.to raise_error(SystemExit)
        end

        it 'call connection#get' do
          @cloud.connection.should_receive(:get).with('/clouds')

          @cloud.list
        end

        it 'call display_list' do
          @cloud.should_receive(:display_list)

          @cloud.list
        end
      end

      describe '#show' do
        before do
          response = double(:response, body: '{ "message": "dummy response"}', success?: true, status: 'dummy status')
          @cloud.stub_chain(:connection, :get).and_return(response)
          @cloud.stub(:display_details)
          @cloud_name = 'dummy_cloud'
        end

        it 'display_details not call if cloud_id nil' do
          @cloud.stub(:find_id_by_name).and_return(nil)
          @cloud.should_not_receive(:display_details)

          expect { @cloud.show @cloud_name }.to raise_error(SystemExit)
        end

        it 'display_details not call if response fail' do
          @cloud.stub_chain(:connection, :get).and_return(double(:response, success?: false, status: 'dummy status'))
          @cloud.should_not_receive(:display_details)

          expect { @cloud.show @cloud_name }.to raise_error(SystemExit)
        end

        it 'call connection#get' do
          @cloud.connection.should_receive(:get).with('/clouds/1')

          @cloud.show @cloud_name
        end

        it 'call display_details' do
          @cloud.should_receive(:display_details)

          @cloud.show @cloud_name
        end
      end

      describe '#create' do
        before do
          response = double(:response, body: '{ "message": "dummy response"}', success?: true, status: 'dummy status')
          @cloud.stub_chain(:connection, :post).and_return(response)
          @cloud.stub(:display_message)
          @cloud.stub(:display_details)
          @options = {
            'name' => 'dummy_name',
            'type' => 'dummy_type',
            'entry_point' => 'dummy_entry_point',
            'key' => 'dummy_key',
            'secret' => 'dummy_secret'
          }
        end

        it 'filter payload' do
          @options['unnecessary_key'] = 'Unnecessary Value'
          @cloud.connection.should_receive(:post).with('/clouds', hash_excluding('unnecessary_key'))

          @cloud.create
        end

        it 'display_details not call if response fail' do
          @cloud.stub_chain(:connection, :post).and_return(double(:response, success?: false, status: 'dummy status'))
          @cloud.should_not_receive(:display_details)

          expect { @cloud.create }.to raise_error(SystemExit)
        end

        it 'call connection#post' do
          payload = {
            'name' => 'dummy_name',
            'type' => 'dummy_type',
            'entry_point' => 'dummy_entry_point',
            'key' => 'dummy_key',
            'secret' => 'dummy_secret'
          }
          @cloud.connection.should_receive(:post).with('/clouds', payload)

          @cloud.create
        end

        it 'call connection#post' do
          @options = {
            'name' => 'dummy_name',
            'type' => 'dummy_type',
            'entry_point' => 'dummy_entry_point',
            'key' => 'dummy_key',
            'secret' => 'dummy_secret',
            'tenant_name' => 'dummy_tenant_name',
            'base_image_id' => 'dummy_base_image'
          }
          @cloud.connection.should_receive(:post).with('/clouds', @options)

          @cloud.create
        end

        it 'call display_details' do
          @cloud.should_receive(:display_details)

          @cloud.create
        end
      end

      describe '#update' do
        before do
          response = double(:response, body: '{ "message": "dummy response"}', success?: true, status: 'dummy status')
          @cloud.stub_chain(:connection, :put).and_return(response)
          @cloud.stub(:display_message)
          @cloud.stub(:display_details)
          @cloud_name = 'dummy_cloud'
        end

        it 'display_details not call if system_id nil' do
          @cloud.stub(:find_id_by_name).and_return(nil)
          @cloud.should_not_receive(:display_details)

          expect { @cloud.update @cloud_name }.to raise_error(SystemExit)
        end

        it 'filter payload' do
          @options['unnecessary_key'] = 'Unnecessary Value'
          @cloud.connection.should_receive(:put).with('/clouds/1', hash_excluding('unnecessary_key'))

          @cloud.update @cloud_name
        end

        it 'display_details not call if response fail' do
          @cloud.stub_chain(:connection, :put).and_return(double(:response, success?: false, status: 'dummy status'))
          @cloud.should_not_receive(:display_details)

          expect { @cloud.update @cloud_name }.to raise_error(SystemExit)
        end

        it 'call connection#put' do
          @cloud.connection.should_receive(:put).with('/clouds/1', {})

          @cloud.update @cloud_name
        end

        it 'call display_details' do
          @cloud.should_receive(:display_details)

          @cloud.update @cloud_name
        end
      end

      describe '#delete' do
        before do
          response = double(:response, body: '{ "message": "dummy response"}', success?: true, status: 'dummy status')
          @cloud.stub_chain(:connection, :delete).and_return(response)
          @cloud.stub(:display_message)
          @cloud_name = 'dummy_cloud'
        end

        it 'display_message not call if cloud_id nil' do
          @cloud.stub(:find_id_by_name).and_return(nil)
          @cloud.should_not_receive(:display_message)

          expect { @cloud.delete @cloud_name }.to raise_error(SystemExit)
        end

        it 'display_message not call if response fail' do
          @cloud.stub_chain(:connection, :delete).and_return(double(:response, success?: false, status: 'dummy status'))
          @cloud.should_not_receive(:display_message)

          expect { @cloud.delete @cloud_name }.to raise_error(SystemExit)
        end

        it 'call connection#delete' do
          @cloud.connection.should_receive(:delete).with('/clouds/1')

          @cloud.delete @cloud_name
        end

        it 'call display_details' do
          @cloud.should_receive(:display_message)

          @cloud.delete @cloud_name
        end
      end
    end
  end
end
