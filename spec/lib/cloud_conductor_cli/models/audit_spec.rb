require 'active_support/core_ext'

module CloudConductorCli
  module Models
    describe System do
      let(:audit) { CloudConductorCli::Models::Audit.new }
      let(:commands) { CloudConductorCli::Models::System.commands }
      let(:mock_audit) do
        {
          id: 1,
          project_id: 1,
          account: 1,
          status: 201,
          request: 'http://test'
        }
      end

      before do
        allow(CloudConductorCli::Helpers::Connection).to receive(:new).and_return(double(get: true, post: true, put: true, delete: true, request: true))
        allow(audit).to receive(:find_id_by).with(:audit, :name, anything, anything).and_return(mock_audit[:id])
        allow(audit).to receive(:find_id_by).with(:system, :name, anything, anything).and_return(1)
        allow(audit).to receive(:find_id_by).with(:project, :name, anything).and_return(1)
        allow(audit).to receive(:find_id_by).with(:environment, :name, anything).and_return(1)
        allow(audit).to receive(:output)
        allow(audit).to receive(:message)
      end

      describe '#list' do
        let(:mock_response) { double(status: 200, headers: [], body: JSON.dump([mock_audit])) }
        before do
          allow(audit.connection).to receive(:get).with('/audits', anything).and_return(mock_response)
        end

        it 'allow valid options' do
          allowed_options = [:project]
          expect(commands['list'].options.keys).to match_array(allowed_options)
        end

        it 'request GET /audits' do
          expect(audit.connection).to receive(:get).with('/audits', 'project_id' => nil)
          audit.list
        end

        it 'display record list' do
          expect(audit).to receive(:output).with(mock_response)
          audit.list
        end

        describe 'with project' do
          it 'request GET /audits' do
            audit.options = { project: 'project_name' }.with_indifferent_access
            expect(audit).to receive(:find_id_by).with(:project, :name, 'project_name')
            expect(audit.connection).to receive(:get).with('/audits', 'project_id' => 1)
            audit.list
          end
        end
      end
    end
  end
end
