require 'active_support/core_ext'

module CloudConductorCli
  module Models
    describe Environment do
      let(:environment) { CloudConductorCli::Models::Environment.new }
      let(:commands) { CloudConductorCli::Models::Environment.commands }
      let(:mock_environment) do
        {
          id: 1,
          system_id: 1,
          blueprint_id: 1,
          name: 'environment_name',
          description: 'environment_description',
          status: 'CREATE_COMPLETE',
          ip_address: '127.0.0.1',
          template_parameters: '{}'
        }
      end
      let(:mock_event) do
        {
          id: '77970fa0-5cd8-49e2-8a3b-4b4502892628',
          name: 'configure',
          status: 'success',
          started_at: '2015-09-14T14:12:35.000+09:00',
          finished_at: '2015-09-14T14:13:10.000+09:00',
          task_results: [{
            id: '77970fa0-5cd8-49e2-8a3b-4b4502892628',
            no: 0,
            name: 'configure',
            status: 'success',
            started_at: '2015-09-14T14:12:45.000+09:00',
            finished_at: '2015-09-14T14:12:52.000+09:00',
            nodes: [{
              id: '77970fa0-5cd8-49e2-8a3b-4b4502892628',
              no: 0,
              node: 'test',
              status: 'success',
              started_at: '2015-09-14T14:12:45.000+09:00',
              finished_at: '2015-09-14T14:12:51.000+09:00',
              log: 'log message'
            }]
          }]
        }
      end

      before do
        allow(CloudConductorCli::Helpers::Connection).to receive(:new).and_return(double(get: true, post: true, put: true, delete: true, request: true))
        allow(environment).to receive(:find_id_by).with(:environment, :name, anything).and_return(mock_environment[:id])
        allow(environment).to receive(:find_id_by).with(:system, :name, anything).and_return(1)
        allow(environment).to receive(:find_id_by).with(:blueprint, :name, anything).and_return(1)
        allow(environment).to receive(:find_id_by).with(:cloud, :name, anything).and_return(1)
        allow(environment).to receive(:output)
        allow(environment).to receive(:message)
        allow(environment).to receive_message_chain(:outputter, :display_detail)
        allow(environment).to receive_message_chain(:outputter, :display_list)
      end

      describe '#list' do
        let(:mock_response) { double(status: 200, headers: [], body: JSON.dump([mock_environment])) }
        before do
          allow(environment.connection).to receive(:get).with('/environments').and_return(mock_response)
        end

        it 'allow valid options' do
          allowed_options = []
          expect(commands['list'].options.keys).to match_array(allowed_options)
        end

        it 'request GET /environments' do
          expect(environment.connection).to receive(:get).with('/environments')
          environment.list
        end

        it 'display record list' do
          expect(environment).to receive(:output).with(mock_response)
          environment.list
        end
      end

      describe '#show' do
        let(:mock_response) { double(status: 200, headers: [], body: JSON.dump(mock_environment)) }
        before do
          allow(environment.connection).to receive(:get).with("/environments/#{mock_environment[:id]}").and_return(mock_response)
        end

        it 'allow valid options' do
          allowed_options = []
          expect(commands['show'].options.keys).to match_array(allowed_options)
        end

        it 'request GET /environments/:id' do
          expect(environment.connection).to receive(:get).with("/environments/#{mock_environment[:id]}")
          environment.show('environment_name')
        end

        it 'display record details' do
          expect(environment).to receive(:output).with(mock_response)
          environment.show('environment_name')
        end
      end

      describe '#create' do
        let(:mock_response) { double(status: 201, headers: [], body: JSON.dump(mock_environment)) }
        before do
          allow(environment.connection).to receive(:post).with('/environments', anything).and_return(mock_response)
          allow(environment).to receive(:build_template_parameters).and_return('{}')
          allow(environment).to receive(:build_user_attributes).and_return('{}')
        end

        it 'allow valid options' do
          allowed_options = [:blueprint, :clouds, :description, :name, :parameter_file, :system, :user_attribute_file]
          expect(commands['create'].options.keys).to match_array(allowed_options)
        end

        it 'request POST /environments with payload' do
          environment.options = mock_environment.except(:id, :system_id, :blueprint_id, :template_parameters, :status, :ip_address)
            .merge('system' => 'system_name', 'blueprint' => 'blueprint_name', 'clouds' => ['cloud_name'])
          payload = environment.options.except('system', 'blueprint', 'clouds')
                    .merge('system_id' => 1, 'blueprint_id' => 1, 'candidates_attributes' => [{ cloud_id: 1, priority: 10 }],
                           'template_parameters' => '{}', 'user_attributes' => '{}')
          expect(environment.connection).to receive(:post).with('/environments', payload)
          environment.create
        end

        it 'display message and record details' do
          environment.options = mock_environment.except(:id, :system_id, :blueprint_id, :template_parameters, :status, :ip_address)
            .merge('system' => 'system_name', 'blueprint' => 'blueprint_name', 'clouds' => ['cloud_name'])
          expect(environment).to receive(:message)
          expect(environment).to receive(:output).with(mock_response)
          environment.create
        end
      end

      describe '#update' do
        let(:mock_response) { double(status: 200, headers: [], body: JSON.dump(mock_environment)) }
        before do
          allow(environment.connection).to receive(:put).with("/environments/#{mock_environment[:id]}", anything).and_return(mock_response)
        end

        it 'allow valid options' do
          allowed_options = [:clouds, :description, :name, :parameter_file, :user_attribute_file]
          expect(commands['update'].options.keys).to match_array(allowed_options)
        end

        it 'request PUT /environments/:id with payload' do
          environment.options = mock_environment.except(:id, :system_id, :blueprint_id, :template_parameters, :status, :ip_address)
            .merge('clouds' => ['cloud_name'])
          payload = environment.options.except('clouds').merge('candidates_attributes' => [{ cloud_id: 1, priority: 10 }])
          expect(environment.connection).to receive(:put).with("/environments/#{mock_environment[:id]}", payload)
          environment.update('environment_name')
        end

        it 'display message and record details' do
          expect(environment).to receive(:message)
          expect(environment).to receive(:output).with(mock_response)
          environment.update('environment_name')
        end
      end

      describe '#delete' do
        let(:mock_response) { double(status: 204, headers: [], body: JSON.dump('')) }
        before do
          allow(environment.connection).to receive(:delete).with("/environments/#{mock_environment[:id]}").and_return(mock_response)
        end

        it 'allow valid options' do
          allowed_options = []
          expect(commands['delete'].options.keys).to match_array(allowed_options)
        end

        it 'request DELETE /environments/:id' do
          expect(environment.connection).to receive(:delete).with("/environments/#{mock_environment[:id]}")
          environment.delete('environment_name')
        end

        it 'display message' do
          expect(environment).to receive(:message)
          environment.delete('environment_name')
        end
      end

      describe '#send_event' do
        let(:mock_response) { double(status: 202, headers: [], body: JSON.dump(event_id: 'xxxxxxxx')) }
        before do
          allow(environment.connection).to receive(:post).with("/environments/#{mock_environment[:id]}/events", anything).and_return(mock_response)
        end

        it 'allow valid options' do
          allowed_options = [:event]
          expect(commands['send_event'].options.keys).to match_array(allowed_options)
        end

        it 'request POST /environments/:id/events with payload' do
          environment.options = { event: 'configure' }
          payload = environment.options
          expect(environment.connection).to receive(:post).with("/environments/#{mock_environment[:id]}/events", payload)
          environment.send_event('environment_name')
        end

        it 'display message and record details' do
          environment.options = { event: 'configure' }
          expect(environment).to receive(:message)
          environment.send_event('environment_name')
        end
      end

      describe '#list_event' do
        let(:mock_response) { double(status: 200, headers: [], body: JSON.dump([mock_event.except(:task_results)])) }
        before do
          allow(environment.connection).to receive(:get).with("/environments/#{mock_environment[:id]}/events").and_return(mock_response)
        end

        it 'allow valid options' do
          allowed_options = []
          expect(commands['list_event'].options.keys).to match_array(allowed_options)
        end

        it 'request GET /environments/:id/events' do
          expect(environment.connection).to receive(:get).with("/environments/#{mock_environment[:id]}/events")
          environment.list_event('environment_name')
        end

        it 'display message and record list' do
          expect(environment).to receive(:output).with(mock_response)
          environment.list_event('environment_name')
        end
      end

      describe '#show_event' do
        let(:mock_response) { double(status: 200, headers: [], body: JSON.dump(mock_event)) }
        before do
          allow(environment.connection).to receive(:get).with("/environments/#{mock_environment[:id]}/events/#{mock_event[:id]}").and_return(mock_response)
        end

        it 'allow valid options' do
          allowed_options = [:event_id]
          expect(commands['show_event'].options.keys).to match_array(allowed_options)
        end

        it 'request GET /environments/:id/events/:id' do
          environment.options = { 'event_id' => mock_event[:id], format: 'table'  }
          expect(environment.connection).to receive(:get).with("/environments/#{mock_environment[:id]}/events/#{mock_event[:id]}")
          environment.show_event('environment_name')
        end

        it 'display message and record list' do
          environment.options = { 'event_id' => mock_event[:id], format: 'table' }
          expect(environment.outputter).to receive(:display_detail).with(mock_event.except(:task_results).stringify_keys)

          expect_task_results = mock_event[:task_results].map { |result| result.except(:nodes).stringify_keys }
          expect(environment.outputter).to receive(:display_list).with(expect_task_results)

          expect_node_results = mock_event[:task_results].map { |result| result[:nodes].map(&:stringify_keys) }.flatten
          expect(environment.outputter).to receive(:display_list).with(expect_node_results)
          environment.show_event('environment_name')
        end
      end
    end
  end
end
