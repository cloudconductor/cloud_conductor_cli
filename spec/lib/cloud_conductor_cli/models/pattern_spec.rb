require 'active_support/core_ext'

module CloudConductorCli
  module Models
    describe Pattern do
      let(:pattern) { CloudConductorCli::Models::Pattern.new }
      let(:commands) { CloudConductorCli::Models::Pattern.commands }
      let(:mock_pattern) do
        {
          id: 1,
          project_id: 1,
          name: 'dummy_pattern',
          type: 'platform',
          protocol: 'git',
          url: 'http://www.example.com/dummy_pattern.git',
          revision: 'develop',
          parameters: '{}',
          roles: 'web, ap, db'
        }
      end

      before do
        allow(CloudConductorCli::Helpers::Connection).to receive(:new).and_return(double(get: true, post: true, put: true, delete: true, request: true))
        allow(pattern).to receive(:find_id_by).with(:pattern, :name, anything, anything).and_return(mock_pattern[:id])
        allow(pattern).to receive(:find_id_by).with(:project, :name, anything).and_return(1)
        allow(pattern).to receive(:output)
        allow(pattern).to receive(:message)
      end

      describe '#list' do
        let(:mock_response) { double(status: 200, headers: [], body: JSON.dump([mock_pattern])) }
        before do
          allow(pattern.connection).to receive(:get).with('/patterns', anything).and_return(mock_response)
        end

        it 'allow valid options' do
          allowed_options = [:project]
          expect(commands['list'].options.keys).to match_array(allowed_options)
        end

        it 'request GET /patterns' do
          expect(pattern.connection).to receive(:get).with('/patterns', 'project_id' => nil)
          pattern.list
        end

        it 'display record list' do
          expect(pattern).to receive(:output).with(mock_response)
          pattern.list
        end

        describe 'with project' do
          it 'request GET /patterns' do
            pattern.options = { project: 'project_name' }.with_indifferent_access
            expect(pattern).to receive(:find_id_by).with(:project, :name, 'project_name')
            expect(pattern.connection).to receive(:get).with('/patterns', 'project_id' => 1)
            pattern.list
          end
        end
      end

      describe '#show' do
        let(:mock_response) { double(status: 200, headers: [], body: JSON.dump(mock_pattern)) }
        before do
          allow(pattern.connection).to receive(:get).with("/patterns/#{mock_pattern[:id]}").and_return(mock_response)
        end

        it 'allow valid options' do
          allowed_options = [:project]
          expect(commands['show'].options.keys).to match_array(allowed_options)
        end

        it 'request GET /patterns/:id' do
          expect(pattern.connection).to receive(:get).with("/patterns/#{mock_pattern[:id]}")
          pattern.show('pattern_name')
        end

        it 'display record details' do
          expect(pattern).to receive(:output).with(mock_response)
          pattern.show('pattern_name')
        end

        describe 'with project' do
          it 'request GET /patterns' do
            pattern.options = { project: 'project_name' }.with_indifferent_access
            expect(pattern).to receive(:find_id_by).with(:project, :name, 'project_name')
            expect(pattern).to receive(:find_id_by).with(:pattern, :name, 'pattern_name', project_id: 1)
            expect(pattern.connection).to receive(:get).with("/patterns/#{mock_pattern[:id]}")
            pattern.show('pattern_name')
          end
        end
      end

      describe '#create' do
        let(:mock_response) { double(status: 201, headers: [], body: JSON.dump(mock_pattern)) }
        before do
          allow(pattern.connection).to receive(:post).with('/patterns', anything).and_return(mock_response)
        end

        it 'allow valid options' do
          allowed_options = [:project, :url, :revision]
          expect(commands['create'].options.keys).to match_array(allowed_options)
        end

        it 'request POST /patterns with payload' do
          except_attributes = %i(id project_id name type protocol parameters roles)
          pattern.options = mock_pattern.except(*except_attributes).merge('project' => 'project_name')
          payload = pattern.options.except('project').merge('project_id' => 1)
          expect(pattern.connection).to receive(:post).with('/patterns', payload)
          pattern.create
        end

        it 'display message and record details' do
          expect(pattern).to receive(:message)
          expect(pattern).to receive(:output).with(mock_response)
          pattern.create
        end
      end

      describe '#update' do
        let(:mock_response) { double(status: 200, headers: [], body: JSON.dump(mock_pattern)) }
        before do
          allow(pattern.connection).to receive(:put).with("/patterns/#{mock_pattern[:id]}", anything).and_return(mock_response)
        end

        it 'allow valid options' do
          allowed_options = [:url, :revision, :project]
          expect(commands['update'].options.keys).to match_array(allowed_options)
        end

        it 'request PUT /patterns/:id with payload' do
          except_attributes = %i(id project_id name type protocol parameters roles)
          pattern.options = mock_pattern.except(*except_attributes)
          payload = pattern.options
          expect(pattern.connection).to receive(:put).with("/patterns/#{mock_pattern[:id]}", payload)
          pattern.update('pattern_name')
        end

        it 'display message and record details' do
          expect(pattern).to receive(:message)
          expect(pattern).to receive(:output).with(mock_response)
          pattern.update('pattern_name')
        end

        describe 'with project' do
          it 'request PUT /patterns/:id with payload' do
            except_attributes = %i(id project_id name type protocol parameters roles)
            pattern.options = mock_pattern.except(*except_attributes)
              .merge(project: 'project_name')
              .with_indifferent_access

            expect(pattern).to receive(:find_id_by).with(:project, :name, 'project_name')
            expect(pattern).to receive(:find_id_by).with(:pattern, :name, 'pattern_name', project_id: 1)

            payload = pattern.options.except('project')
            expect(pattern.connection).to receive(:put).with("/patterns/#{mock_pattern[:id]}", payload)
            pattern.update('pattern_name')
          end
        end
      end

      describe '#delete' do
        let(:mock_response) { double(status: 204, headers: [], body: JSON.dump('')) }
        before do
          allow(pattern.connection).to receive(:delete).with("/patterns/#{mock_pattern[:id]}").and_return(mock_response)
        end

        it 'allow valid options' do
          allowed_options = [:project]
          expect(commands['delete'].options.keys).to match_array(allowed_options)
        end

        it 'request DELETE /patterns/:id' do
          expect(pattern.connection).to receive(:delete).with("/patterns/#{mock_pattern[:id]}")
          pattern.delete('pattern_name')
        end

        it 'display message' do
          expect(pattern).to receive(:message)
          pattern.delete('pattern_name')
        end

        describe 'with project' do
          it 'request DELETE /patterns/:id' do
            pattern.options = { project: 'project_name' }.with_indifferent_access
            expect(pattern).to receive(:find_id_by).with(:project, :name, 'project_name')
            expect(pattern).to receive(:find_id_by).with(:pattern, :name, 'pattern_name', project_id: 1)

            expect(pattern.connection).to receive(:delete).with("/patterns/#{mock_pattern[:id]}")
            pattern.delete('pattern_name')
          end
        end
      end
    end
  end
end
