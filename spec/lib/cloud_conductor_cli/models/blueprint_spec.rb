require 'active_support/core_ext'

module CloudConductorCli
  module Models
    describe Blueprint do
      let(:blueprint) { CloudConductorCli::Models::Blueprint.new }
      let(:commands) { CloudConductorCli::Models::Blueprint.commands }
      let(:mock_blueprint) do
        {
          id: 1,
          project_id: 1,
          name: 'blueprint_name',
          description: 'blueprint description'
        }.with_indifferent_access
      end
      let(:mock_blueprint_history) do
        {
          id: 1,
          blueprint_id: 1,
          version: 1,
          consul_secret_key: 'Osc+R7O6NwYJFxm6Zqcxww=='
        }.with_indifferent_access
      end
      let(:mock_blueprint_pattern) do
        {
          id: 1,
          blueprint_id: 1,
          pattern_id: 1,
          revision: 'develop',
          os_version: 'CentOS-6.5'
        }.with_indifferent_access
      end

      before do
        allow(CloudConductorCli::Helpers::Connection).to receive(:new).and_return(double(get: true, post: true, put: true, delete: true, request: true))
        allow(blueprint).to receive(:find_id_by).with(:blueprint, :name, anything, anything).and_return(mock_blueprint[:id])
        allow(blueprint).to receive(:find_id_by).with(:project, :name, anything).and_return(1)
        allow(blueprint).to receive(:find_id_by).with(:pattern, :name, anything, anything).and_return(1)
        allow(blueprint).to receive(:output)
        allow(blueprint).to receive(:message)
      end

      describe '#list' do
        let(:mock_response) { double(status: 200, headers: [], body: JSON.dump([mock_blueprint])) }
        before do
          allow(blueprint.connection).to receive(:get).with('/blueprints', anything).and_return(mock_response)
        end

        it 'allow valid options' do
          allowed_options = [:project]
          expect(commands['list'].options.keys).to match_array(allowed_options)
        end

        it 'request GET /blueprints' do
          expect(blueprint.connection).to receive(:get).with('/blueprints', 'project_id' => nil)
          blueprint.list
        end

        it 'display record list' do
          expect(blueprint).to receive(:output).with(mock_response)
          blueprint.list
        end

        describe 'with project' do
          it 'request GET /blueprints' do
            blueprint.options = { project: 'project_name' }.with_indifferent_access
            expect(blueprint).to receive(:find_id_by).with(:project, :name, 'project_name')
            expect(blueprint.connection).to receive(:get).with('/blueprints', project_id: 1)
            blueprint.list
          end
        end
      end

      describe '#show' do
        let(:mock_response) { double(status: 200, headers: [], body: JSON.dump(mock_blueprint)) }
        before do
          allow(blueprint.connection).to receive(:get).with("/blueprints/#{mock_blueprint[:id]}").and_return(mock_response)
        end

        it 'allow valid options' do
          allowed_options = [:project]
          expect(commands['show'].options.keys).to match_array(allowed_options)
        end

        it 'request GET /blueprints/:id' do
          expect(blueprint.connection).to receive(:get).with("/blueprints/#{mock_blueprint[:id]}")
          blueprint.show('blueprint_name')
        end

        it 'display record details' do
          expect(blueprint).to receive(:output).with(mock_response)
          blueprint.show('blueprint_name')
        end

        describe 'with project' do
          it 'request GET /blueprints/:id' do
            blueprint.options = { project: 'project_name' }.with_indifferent_access
            expect(blueprint).to receive(:find_id_by).with(:project, :name, 'project_name')
            expect(blueprint).to receive(:find_id_by).with(:blueprint, :name, 'blueprint_name', project_id: 1)
            expect(blueprint.connection).to receive(:get).with("/blueprints/#{mock_blueprint[:id]}")
            blueprint.show('blueprint_name')
          end
        end
      end

      describe '#create' do
        let(:mock_response) { double(status: 201, headers: [], body: JSON.dump(mock_blueprint)) }
        before do
          allow(blueprint.connection).to receive(:post).with('/blueprints', anything).and_return(mock_response)
        end

        it 'allow valid options' do
          allowed_options = [:project, :name, :description]
          expect(commands['create'].options.keys).to match_array(allowed_options)
        end

        it 'request POST /blueprints with payload' do
          blueprint.options = mock_blueprint.except(:id, :project_id).merge(project: 'project_name')
          payload = blueprint.options.except(:project).merge(project_id: 1)
          expect(blueprint.connection).to receive(:post).with('/blueprints', payload)
          blueprint.create
        end

        it 'display message and record details' do
          expect(blueprint).to receive(:message)
          expect(blueprint).to receive(:output).with(mock_response)
          blueprint.create
        end
      end

      describe '#update' do
        let(:mock_response) { double(status: 200, headers: [], body: JSON.dump(mock_blueprint)) }
        before do
          allow(blueprint.connection).to receive(:put).with("/blueprints/#{mock_blueprint[:id]}", anything).and_return(mock_response)
        end

        it 'allow valid options' do
          allowed_options = [:name, :description, :project]
          expect(commands['update'].options.keys).to match_array(allowed_options)
        end

        it 'request PUT /blueprints/:id with payload' do
          blueprint.options = mock_blueprint.except(:id, :project_id)
          expect(blueprint.connection).to receive(:put).with("/blueprints/#{mock_blueprint[:id]}", blueprint.options)
          blueprint.update('blueprint_name')
        end

        it 'display message and record details' do
          expect(blueprint).to receive(:message)
          expect(blueprint).to receive(:output).with(mock_response)
          blueprint.update('blueprint_name')
        end

        describe 'with project' do
          it 'request PUT /blueprints/:id with payload' do
            blueprint.options = mock_blueprint.except(:id, :project_id)
              .merge(project: 'project_name').with_indifferent_access
            expect(blueprint).to receive(:find_id_by).with(:project, :name, 'project_name')
            expect(blueprint).to receive(:find_id_by).with(:blueprint, :name, 'blueprint_name', project_id: 1)
            payload = blueprint.options.except(:project)
            expect(blueprint.connection).to receive(:put).with("/blueprints/#{mock_blueprint[:id]}", payload)
            blueprint.update('blueprint_name')
          end
        end
      end

      describe '#delete' do
        let(:mock_response) { double(status: 204, headers: [], body: JSON.dump('')) }
        before do
          allow(blueprint.connection).to receive(:delete).with("/blueprints/#{mock_blueprint[:id]}").and_return(mock_response)
        end

        it 'allow valid options' do
          allowed_options = [:project]
          expect(commands['delete'].options.keys).to match_array(allowed_options)
        end

        it 'request DELETE /blueprints/:id' do
          expect(blueprint.connection).to receive(:delete).with("/blueprints/#{mock_blueprint[:id]}")
          blueprint.delete('blueprint_name')
        end

        it 'display message' do
          expect(blueprint).to receive(:message)
          blueprint.delete('blueprint_name')
        end

        describe 'with project' do
          it 'request DELETE /blueprints/:id' do
            blueprint.options = { project: 'project_name' }.with_indifferent_access
            expect(blueprint).to receive(:find_id_by).with(:project, :name, 'project_name')
            expect(blueprint).to receive(:find_id_by).with(:blueprint, :name, 'blueprint_name', project_id: 1)
            expect(blueprint.connection).to receive(:delete).with("/blueprints/#{mock_blueprint[:id]}")
            blueprint.delete('blueprint_name')
          end
        end
      end

      describe '#build' do
        let(:mock_response) { double(status: 202, headers: [], body: JSON.dump(mock_blueprint_history)) }
        before do
          allow(blueprint.connection).to receive(:post).with("/blueprints/#{mock_blueprint[:id]}/build").and_return(mock_response)
        end

        it 'allow valid options' do
          allowed_options = [:project]
          expect(commands['build'].options.keys).to match_array(allowed_options)
        end

        it 'request POST /blueprints/:id/build with payload' do
          expect(blueprint.connection).to receive(:post).with("/blueprints/#{mock_blueprint[:id]}/build")
          blueprint.build('blueprint_name')
        end

        it 'display message and record details' do
          expect(blueprint).to receive(:message)
          expect(blueprint).to receive(:output).with(mock_response)
          blueprint.build('blueprint_name')
        end

        describe 'with project' do
          it 'request POST /blueprints/:id/build with payload' do
            blueprint.options = { project: 'project_name' }.with_indifferent_access
            expect(blueprint).to receive(:find_id_by).with(:project, :name, 'project_name')
            expect(blueprint).to receive(:find_id_by).with(:blueprint, :name, 'blueprint_name', project_id: 1)
            expect(blueprint.connection).to receive(:post).with("/blueprints/#{mock_blueprint[:id]}/build")
            blueprint.build('blueprint_name')
          end
        end
      end

      describe '#pattern_list' do
        let(:mock_response) { double(status: 200, headers: [], body: JSON.dump([mock_blueprint_pattern])) }
        before do
          allow(blueprint.connection).to receive(:get).with("/blueprints/#{mock_blueprint[:id]}/patterns").and_return(mock_response)
        end

        it 'allow valid options' do
          allowed_options = [:project]
          expect(commands['pattern_list'].options.keys).to match_array(allowed_options)
        end

        it 'request GET /blueprints/:id/patterns' do
          expect(blueprint.connection).to receive(:get).with("/blueprints/#{mock_blueprint[:id]}/patterns")
          blueprint.pattern_list('blueprint_name')
        end

        it 'display record list' do
          expect(blueprint).to receive(:output).with(mock_response)
          blueprint.pattern_list('blueprint_name')
        end

        describe 'with project' do
          it 'request GET /blueprints/:id/patterns' do
            blueprint.options = { project: 'project_name' }.with_indifferent_access
            expect(blueprint).to receive(:find_id_by).with(:project, :name, 'project_name')
            expect(blueprint).to receive(:find_id_by).with(:blueprint, :name, 'blueprint_name', project_id: 1)
            expect(blueprint.connection).to receive(:get).with("/blueprints/#{mock_blueprint[:id]}/patterns")
            blueprint.pattern_list('blueprint_name')
          end
        end
      end

      describe '#pattern_add' do
        let(:mock_response) { double(status: 201, headers: [], body: JSON.dump(mock_blueprint_pattern)) }
        before do
          allow(blueprint.connection).to receive(:post).with("/blueprints/#{mock_blueprint[:id]}/patterns", anything).and_return(mock_response)
        end

        it 'allow valid options' do
          allowed_options = [:pattern, :revision, :os_version, :project]
          expect(commands['pattern_add'].options.keys).to match_array(allowed_options)
        end

        it 'request POST /blueprints/:id/patterns with payload' do
          blueprint.options = mock_blueprint_pattern.except(:id, :blueprint_id, :pattern_id).merge(pattern: 'pattern_name')
          payload = blueprint.options.except('pattern').merge(pattern_id: 1)
          expect(blueprint.connection).to receive(:post).with("/blueprints/#{mock_blueprint[:id]}/patterns", payload)
          blueprint.pattern_add('blueprint_name')
        end

        it 'display message and record details' do
          expect(blueprint).to receive(:message)
          expect(blueprint).to receive(:output).with(mock_response)
          blueprint.pattern_add('blueprint_name')
        end

        describe 'with project' do
          it 'request POST /blueprints/:id/patterns with payload' do
            blueprint.options = mock_blueprint_pattern.except(:id, :blueprint_id, :pattern_id)
              .merge(pattern: 'pattern_name', project: 'project_name').with_indifferent_access
            expect(blueprint).to receive(:find_id_by).with(:project, :name, 'project_name')
            expect(blueprint).to receive(:find_id_by).with(:blueprint, :name, 'blueprint_name', project_id: 1)
            expect(blueprint).to receive(:find_id_by).with(:pattern, :name, 'pattern_name', project_id: 1)

            payload = blueprint.options.except('pattern', 'project').merge(pattern_id: 1)
            expect(blueprint.connection).to receive(:post).with("/blueprints/#{mock_blueprint[:id]}/patterns", payload)
            blueprint.pattern_add('blueprint_name')
          end
        end
      end

      describe '#pattern_update' do
        let(:url) { "/blueprints/#{mock_blueprint[:id]}/patterns/#{mock_blueprint_pattern[:pattern_id]}" }
        let(:mock_response) { double(status: 200, headers: [], body: JSON.dump(mock_blueprint_pattern)) }
        before do
          allow(blueprint.connection).to receive(:put).with(url, anything).and_return(mock_response)
        end

        it 'allow valid options' do
          allowed_options = [:pattern, :revision, :os_version, :project]
          expect(commands['pattern_update'].options.keys).to match_array(allowed_options)
        end

        it 'request PUT /blueprints/:id/patterns/:pattern_id with payload' do
          blueprint.options = mock_blueprint_pattern.except(:id, :blueprint_id, :pattern_id).merge(pattern: 'pattern_name')
          payload = blueprint.options.except('pattern')
          expect(blueprint.connection).to receive(:put).with(url, payload)
          blueprint.pattern_update('blueprint_name')
        end

        it 'display message and record details' do
          expect(blueprint).to receive(:message)
          expect(blueprint).to receive(:output).with(mock_response)
          blueprint.pattern_update('blueprint_name')
        end

        describe 'with project' do
          it 'request PUT /blueprints/:id/patterns/:pattern_id with payload' do
            blueprint.options = mock_blueprint_pattern.except(:id, :blueprint_id, :pattern_id)
              .merge(pattern: 'pattern_name', project: 'project_name').with_indifferent_access
            expect(blueprint).to receive(:find_id_by).with(:project, :name, 'project_name')
            expect(blueprint).to receive(:find_id_by).with(:blueprint, :name, 'blueprint_name', project_id: 1)
            expect(blueprint).to receive(:find_id_by).with(:pattern, :name, 'pattern_name', project_id: 1)

            payload = blueprint.options.except('pattern', 'project')
            expect(blueprint.connection).to receive(:put).with(url, payload)
            blueprint.pattern_update('blueprint_name')
          end
        end
      end

      describe '#pattern_delete' do
        let(:url) { "/blueprints/#{mock_blueprint[:id]}/patterns/#{mock_blueprint_pattern[:pattern_id]}" }
        let(:mock_response) { double(status: 204, headers: [], body: JSON.dump('')) }
        before do
          allow(blueprint.connection).to receive(:delete).with(url).and_return(mock_response)
        end

        it 'allow valid options' do
          allowed_options = [:pattern, :project]
          expect(commands['pattern_delete'].options.keys).to match_array(allowed_options)
        end

        it 'request DELETE /blueprints/:id/patterns/:pattern_id' do
          expect(blueprint.connection).to receive(:delete).with("/blueprints/#{mock_blueprint[:id]}/patterns/#{mock_blueprint_pattern[:pattern_id]}")
          blueprint.pattern_delete('blueprint_name')
        end

        it 'display message and record details' do
          expect(blueprint).to receive(:message)
          blueprint.pattern_delete('blueprint_name')
        end

        describe 'with project' do
          it 'request DELETE /blueprints/:id/patterns/:pattern_id' do
            blueprint.options = { pattern: 'pattern_name', project: 'project_name' }.with_indifferent_access
            expect(blueprint).to receive(:find_id_by).with(:project, :name, 'project_name')
            expect(blueprint).to receive(:find_id_by).with(:blueprint, :name, 'blueprint_name', project_id: 1)
            expect(blueprint).to receive(:find_id_by).with(:pattern, :name, 'pattern_name', project_id: 1)

            expect(blueprint.connection).to receive(:delete).with("/blueprints/#{mock_blueprint[:id]}/patterns/#{mock_blueprint_pattern[:pattern_id]}")
            blueprint.pattern_delete('blueprint_name')
          end
        end
      end

      describe '#history-list' do
        let(:url) { "/blueprints/#{mock_blueprint_history[:blueprint_id]}/histories" }
        let(:mock_response) { double(status: 200, headers: [], body: JSON.dump([mock_blueprint_history])) }
        before do
          allow(blueprint.connection).to receive(:get).with(url).and_return(mock_response)
        end

        it 'allow valid options' do
          allowed_options = [:project]
          expect(commands['history_list'].options.keys).to match_array(allowed_options)
        end

        it 'request GET /blueprints/:id/histories' do
          expect(blueprint.connection).to receive(:get).with(url)
          blueprint.history_list('blueprint_name')
        end

        it 'display record list' do
          expect(blueprint).to receive(:output).with(mock_response)
          blueprint.history_list('blueprint_name')
        end

        describe 'with project' do
          it 'request GET /blueprints/:id/histories' do
            blueprint.options = { project: 'project_name' }.with_indifferent_access
            expect(blueprint).to receive(:find_id_by).with(:project, :name, 'project_name')
            expect(blueprint).to receive(:find_id_by).with(:blueprint, :name, 'blueprint_name', project_id: 1)

            expect(blueprint.connection).to receive(:get).with(url)
            blueprint.history_list('blueprint_name')
          end
        end
      end

      describe '#history-show' do
        let(:url) { "/blueprints/#{mock_blueprint_history[:blueprint_id]}/histories/#{mock_blueprint_history[:version]}" }
        let(:mock_response) { double(status: 200, headers: [], body: JSON.dump(mock_blueprint_history)) }
        before do
          allow(blueprint.connection).to receive(:get).with(url).and_return(mock_response)
          allow(blueprint).to receive_message_chain(:outputter, :display_detail)
          allow(blueprint).to receive_message_chain(:outputter, :display_list)
        end

        it 'allow valid options' do
          allowed_options = [:version, :project]
          expect(commands['history_show'].options.keys).to match_array(allowed_options)
        end

        it 'request GET /blueprints/:id/histories/:version' do
          blueprint.options = { version: mock_blueprint_history[:version], format: 'table' }
          expect(blueprint.connection).to receive(:get).with(url)
          blueprint.history_show('blueprint_name')
        end

        it 'display record details' do
          blueprint.options = { version: mock_blueprint_history[:version], format: 'table' }
          expect(blueprint.outputter).to receive(:display_detail).with(mock_blueprint_history.except(:pattern_snapshots).stringify_keys)
          pattern_snapshots = mock_blueprint_history[:pattern_snapshots]
          expect(blueprint.outputter).to receive(:display_list).with(pattern_snapshots)
          blueprint.history_show('blueprint_name')
        end

        describe 'with project' do
          it 'request GET /blueprints/:id/histories/:version' do
            blueprint.options = { version: mock_blueprint_history[:version], format: 'table', project: 'project_name' }.with_indifferent_access
            expect(blueprint).to receive(:find_id_by).with(:project, :name, 'project_name')
            expect(blueprint).to receive(:find_id_by).with(:blueprint, :name, 'blueprint_name', project_id: 1)
            expect(blueprint.connection).to receive(:get).with(url)
            blueprint.history_show('blueprint_name')
          end
        end
      end

      describe '#history-delete' do
        let(:url) { "/blueprints/#{mock_blueprint_history[:blueprint_id]}/histories/#{mock_blueprint_history[:version]}" }
        let(:mock_response) { double(status: 204, headers: [], body: JSON.dump('')) }
        before do
          allow(blueprint.connection).to receive(:delete).with(url).and_return(mock_response)
        end

        it 'allow valid options' do
          allowed_options = [:version, :project]
          expect(commands['history_delete'].options.keys).to match_array(allowed_options)
        end

        it 'request DELETE /blueprints/:id/histories/:version' do
          blueprint.options = { version: mock_blueprint_history[:version] }
          expect(blueprint.connection).to receive(:delete).with(url)
          blueprint.history_delete('blueprint_name')
        end

        it 'display message' do
          blueprint.options = { version: mock_blueprint_history[:version] }
          expect(blueprint).to receive(:message)
          blueprint.history_delete('blueprint_name')
        end

        describe 'with project' do
          it 'request DELETE /blueprints/:id/histories/:version' do
            blueprint.options = { version: mock_blueprint_history[:version], project: 'project_name' }.with_indifferent_access
            expect(blueprint).to receive(:find_id_by).with(:project, :name, 'project_name')
            expect(blueprint).to receive(:find_id_by).with(:blueprint, :name, 'blueprint_name', project_id: 1)
            expect(blueprint.connection).to receive(:delete).with(url)
            blueprint.history_delete('blueprint_name')
          end
        end
      end
    end
  end
end
