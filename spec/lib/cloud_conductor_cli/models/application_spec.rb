require 'active_support/core_ext'

module CloudConductorCli
  module Models
    describe Application do
      let(:application) { CloudConductorCli::Models::Application.new }
      let(:commands) { CloudConductorCli::Models::Application.commands }
      let(:mock_application) do
        {
          id: 1,
          system_id: 1,
          name: 'application_name',
          description: 'application_description'
        }
      end
      let(:mock_application_history) do
        {
          id: 1,
          application_id: 1,
          version: '20150123-001',
          type: 'dynamic',
          protocol: 'git',
          url: 'http://example.com/repo.git',
          revision: 'master',
          pre_deploy: '',
          post_deploy: '',
          parameters: '{}'
        }
      end
      let(:mock_deployment) do
        {
          id: 1,
          application_history_id: 1,
          environment_id: 1,
          status: 'PENDING'
        }
      end

      before do
        allow(CloudConductorCli::Helpers::Connection).to receive(:new).and_return(double(get: true, post: true, put: true, delete: true, request: true))
        allow(application).to receive(:find_id_by).with(:application, :name, anything, anything).and_return(mock_application[:id])
        allow(application).to receive(:find_id_by).with(:history, :version, any_args).and_return(mock_application_history[:id])
        allow(application).to receive(:find_id_by).with(:system, :name, anything, anything).and_return(1)
        allow(application).to receive(:find_id_by).with(:environment, :name, anything, anything).and_return(1)
        allow(application).to receive(:find_id_by).with(:project, :name, anything).and_return(1)
        allow(application).to receive(:output)
        allow(application).to receive(:message)
      end

      describe '#list' do
        let(:mock_response) { double(status: 200, headers: [], body: JSON.dump([mock_application])) }
        before do
          allow(application.connection).to receive(:get).with('/applications', anything).and_return(mock_response)
        end

        it 'allow valid options' do
          allowed_options = [:system, :project]
          expect(commands['list'].options.keys).to match_array(allowed_options)
        end

        it 'request GET /applications' do
          expect(application.connection).to receive(:get).with('/applications', 'system_id' => nil, 'project_id' => nil)
          application.list
        end

        it 'display record list' do
          expect(application).to receive(:output).with(mock_response)
          application.list
        end

        context 'with system' do
          it 'request GET /applications' do
            application.options = { system: 'system_name' }.with_indifferent_access
            expect(application).to_not receive(:find_id_by).with(:project, :name, anything)
            expect(application).to receive(:find_id_by).with(:system, :name, 'system_name', project_id: nil)
            expect(application.connection).to receive(:get).with('/applications', 'system_id' => 1, 'project_id' => nil)
            application.list
          end
        end

        context 'with project' do
          it 'request GET /applications' do
            application.options = { project: 'project_name' }.with_indifferent_access
            expect(application).to receive(:find_id_by).with(:project, :name, 'project_name')
            expect(application).to_not receive(:find_id_by).with(:system, :name, anything, anything)

            expect(application.connection).to receive(:get).with('/applications', 'system_id' => nil, 'project_id' => 1)
            application.list
          end
        end

        context 'with system and project' do
          it 'request GET /applications' do
            application.options = { system: 'system_name', project: 'project_name' }.with_indifferent_access
            expect(application).to receive(:find_id_by).with(:project, :name, 'project_name')
            expect(application).to receive(:find_id_by).with(:system, :name, 'system_name', project_id: 1)

            expect(application.connection).to receive(:get).with('/applications', 'system_id' => 1, 'project_id' => 1)
            application.list
          end
        end
      end

      describe '#show' do
        let(:mock_response) { double(status: 200, headers: [], body: JSON.dump(mock_application)) }
        let(:mock_response_history) { double(status: 200, headers: [], body: JSON.dump(mock_application_history)) }
        let(:mock_response_histories) { double(status: 200, headers: [], body: JSON.dump([mock_application_history])) }
        before do
          allow(application.connection).to receive(:get).with("/applications/#{mock_application[:id]}").and_return(mock_response)
          allow(application.connection).to receive(:get).with("/applications/#{mock_application[:id]}/histories")
            .and_return(mock_response_histories)
          allow(application.connection).to receive(:get).with("/applications/#{mock_application[:id]}/histories/#{mock_application_history[:id]}")
            .and_return(mock_response_history)
        end

        it 'allow valid options' do
          allowed_options = [:version, :system, :project]
          expect(commands['show'].options.keys).to match_array(allowed_options)
        end

        context 'without version' do
          it 'request GET /applications/:id and GET /applications/:id/histories' do
            expect(application.connection).to receive(:get).with("/applications/#{mock_application[:id]}")
            expect(application.connection).to receive(:get).with("/applications/#{mock_application[:id]}/histories")
            application.show('application_name')
          end

          it 'display record details' do
            expect(application).to receive(:output).with(mock_response)
            expect(application).to receive(:output).with(mock_response_histories)
            application.show('application_name')
          end
        end

        context 'with version' do
          before { application.options = { version: mock_application_history[:version] } }

          it 'request GET /applications/:id and GET /applications/:id/histories/:id' do
            expect(application.connection).to receive(:get).with("/applications/#{mock_application[:id]}")
            expect(application.connection).to receive(:get).with("/applications/#{mock_application[:id]}/histories/#{mock_application_history[:id]}")
            application.show('application_name')
          end

          it 'display record details' do
            expect(application).to receive(:output).with(mock_response)
            expect(application).to receive(:output).with(mock_response_history)
            application.show('application_name')
          end
        end

        context 'with system' do
          it 'request GET /applications/:id and GET /applications/:id/histories/:id' do
            application.options = { system: 'system_name' }.with_indifferent_access
            expect(application).to_not receive(:find_id_by).with(:project, :name, anything)
            expect(application).to receive(:find_id_by).with(:system, :name, 'system_name', project_id: nil)
            expect(application).to receive(:find_id_by).with(:application, :name, 'application_name', system_id: 1, project_id: nil)

            expect(application.connection).to receive(:get).with("/applications/#{mock_application[:id]}")
            expect(application.connection).to receive(:get).with("/applications/#{mock_application[:id]}/histories")
            application.show('application_name')
          end
        end

        context 'with project' do
          it 'request GET /applications/:id and GET /applications/:id/histories/:id' do
            application.options = { project: 'project_name' }.with_indifferent_access
            expect(application).to receive(:find_id_by).with(:project, :name, 'project_name')
            expect(application).to_not receive(:find_id_by).with(:system, :name, anything, anything)
            expect(application).to receive(:find_id_by).with(:application, :name, 'application_name', system_id: nil, project_id: 1)

            expect(application.connection).to receive(:get).with("/applications/#{mock_application[:id]}")
            expect(application.connection).to receive(:get).with("/applications/#{mock_application[:id]}/histories")
            application.show('application_name')
          end
        end

        context 'with system and project' do
          it 'request GET /applications/:id and GET /applications/:id/histories/:id' do
            application.options = { system: 'system_name', project: 'project_name' }.with_indifferent_access
            expect(application).to receive(:find_id_by).with(:project, :name, 'project_name')
            expect(application).to receive(:find_id_by).with(:system, :name, 'system_name', project_id: 1)
            expect(application).to receive(:find_id_by).with(:application, :name, 'application_name', system_id: 1, project_id: 1)

            expect(application.connection).to receive(:get).with("/applications/#{mock_application[:id]}")
            expect(application.connection).to receive(:get).with("/applications/#{mock_application[:id]}/histories")
            application.show('application_name')
          end
        end
      end

      describe '#create' do
        let(:mock_response) { double(status: 201, headers: [], body: JSON.dump(mock_application)) }
        before do
          allow(application.connection).to receive(:post).with('/applications', anything).and_return(mock_response)
        end

        it 'allow valid options' do
          allowed_options = [:system, :name, :description, :domain, :project]
          expect(commands['create'].options.keys).to match_array(allowed_options)
        end

        it 'request POST /applications with payload' do
          application.options = mock_application.except(:id, :system_id).merge('system' => 'system_name')
          payload = application.options.except('system').merge('system_id' => 1)
          expect(application.connection).to receive(:post).with('/applications', payload)
          application.create
        end

        it 'display message and record details' do
          expect(application).to receive(:message)
          expect(application).to receive(:output).with(mock_response)
          application.create
        end

        context 'with project' do
          it 'request POST /applications with payload' do
            application.options = mock_application.except(:id, :system_id)
              .merge(system: 'system_name', project: 'project_name')
              .with_indifferent_access

            expect(application).to receive(:find_id_by).with(:project, :name, 'project_name')
            expect(application).to receive(:find_id_by).with(:system, :name, 'system_name', project_id: 1)

            payload = application.options.except('system', 'project').merge('system_id' => 1)
            expect(application.connection).to receive(:post).with('/applications', payload)
            application.create
          end
        end
      end

      describe '#update' do
        let(:mock_response) { double(status: 200, headers: [], body: JSON.dump(mock_application)) }
        before do
          allow(application.connection).to receive(:put).with("/applications/#{mock_application[:id]}", anything).and_return(mock_response)
        end

        it 'allow valid options' do
          allowed_options = [:name, :description, :domain, :system, :project]
          expect(commands['update'].options.keys).to match_array(allowed_options)
        end

        it 'request PUT /applications/:id with payload' do
          application.options = mock_application.except(:id, :system_id)
          payload = application.options
          expect(application.connection).to receive(:put).with("/applications/#{mock_application[:id]}", payload)
          application.update('application_name')
        end

        it 'display message and record details' do
          expect(application).to receive(:message)
          expect(application).to receive(:output).with(mock_response)
          application.update('application_name')
        end

        context 'with system' do
          it 'request PUT /applications/:id with payload' do
            application.options = mock_application.except(:id, :system_id)
              .merge(system: 'system_name')
              .with_indifferent_access

            expect(application).to_not receive(:find_id_by).with(:project, :name, anything)
            expect(application).to receive(:find_id_by).with(:system, :name, 'system_name', project_id: nil)
            expect(application).to receive(:find_id_by).with(:application, :name, 'application_name', system_id: 1, project_id: nil)

            payload = application.options.except('system', 'project')
            expect(application.connection).to receive(:put).with("/applications/#{mock_application[:id]}", payload)
            application.update('application_name')
          end
        end

        context 'with project' do
          it 'request PUT /applications/:id with payload' do
            application.options = mock_application.except(:id, :system_id)
              .merge(project: 'project_name')
              .with_indifferent_access

            expect(application).to receive(:find_id_by).with(:project, :name, 'project_name')
            expect(application).to_not receive(:find_id_by).with(:system, :name, anything, anything)
            expect(application).to receive(:find_id_by).with(:application, :name, 'application_name', system_id: nil, project_id: 1)

            payload = application.options.except('system', 'project')
            expect(application.connection).to receive(:put).with("/applications/#{mock_application[:id]}", payload)
            application.update('application_name')
          end
        end

        context 'with project and system' do
          it 'request PUT /applications/:id with payload' do
            application.options = mock_application.except(:id, :system_id)
              .merge(system: 'system_name', project: 'project_name')
              .with_indifferent_access

            expect(application).to receive(:find_id_by).with(:project, :name, 'project_name')
            expect(application).to receive(:find_id_by).with(:system, :name, 'system_name', project_id: 1)
            expect(application).to receive(:find_id_by).with(:application, :name, 'application_name', system_id: 1, project_id: 1)

            payload = application.options.except('system', 'project')
            expect(application.connection).to receive(:put).with("/applications/#{mock_application[:id]}", payload)
            application.update('application_name')
          end
        end
      end

      describe '#delete' do
        let(:mock_response) { double(status: 204, headers: [], body: JSON.dump('')) }
        before do
          allow(application.connection).to receive(:delete).with("/applications/#{mock_application[:id]}").and_return(mock_response)
        end

        it 'allow valid options' do
          allowed_options = [:system, :project]
          expect(commands['delete'].options.keys).to match_array(allowed_options)
        end

        it 'request DELETE /applications/:id' do
          expect(application.connection).to receive(:delete).with("/applications/#{mock_application[:id]}")
          application.delete('application_name')
        end

        it 'display message' do
          expect(application).to receive(:message)
          application.delete('application_name')
        end

        context 'with system' do
          it 'request DELETE /applications/:id' do
            application.options = { system: 'system_name' }.with_indifferent_access

            expect(application).to_not receive(:find_id_by).with(:project, :name, 'anything')
            expect(application).to receive(:find_id_by).with(:system, :name, 'system_name', project_id: nil)
            expect(application).to receive(:find_id_by).with(:application, :name, 'application_name', system_id: 1, project_id: nil)

            expect(application.connection).to receive(:delete).with("/applications/#{mock_application[:id]}")
            application.delete('application_name')
          end
        end

        context 'with project' do
          it 'request DELETE /applications/:id' do
            application.options = { project: 'project_name' }.with_indifferent_access

            expect(application).to receive(:find_id_by).with(:project, :name, 'project_name')
            expect(application).to_not receive(:find_id_by).with(:system, :name, anything, anything)
            expect(application).to receive(:find_id_by).with(:application, :name, 'application_name', system_id: nil, project_id: 1)

            expect(application.connection).to receive(:delete).with("/applications/#{mock_application[:id]}")
            application.delete('application_name')
          end
        end

        context 'with project and system' do
          it 'request DELETE /applications/:id' do
            application.options = { system: 'system_name', project: 'project_name' }.with_indifferent_access

            expect(application).to receive(:find_id_by).with(:project, :name, 'project_name')
            expect(application).to receive(:find_id_by).with(:system, :name, 'system_name', project_id: 1)
            expect(application).to receive(:find_id_by).with(:application, :name, 'application_name', system_id: 1, project_id: 1)

            expect(application.connection).to receive(:delete).with("/applications/#{mock_application[:id]}")
            application.delete('application_name')
          end
        end
      end

      describe '#release' do
        let(:mock_response) { double(status: 201, headers: [], body: JSON.dump(mock_application_history)) }
        before do
          allow(application.connection).to receive(:post).with("/applications/#{mock_application[:id]}/histories", anything).and_return(mock_response)
        end

        it 'allow valid options' do
          allowed_options = [:protocol, :url, :revision, :type, :pre_deploy, :post_deploy, :parameters, :system, :project]
          expect(commands['release'].options.keys).to match_array(allowed_options)
        end

        it 'request POST /applications/:id/histories with payload' do
          application.options = mock_application_history.except(:id, :application_id, :version)
          payload = application.options
          expect(application.connection).to receive(:post).with("/applications/#{mock_application[:id]}/histories", payload)
          application.release(mock_application[:name])
        end

        it 'display message and record details' do
          expect(application).to receive(:message)
          expect(application).to receive(:output).with(mock_response)
          application.release(mock_application[:name])
        end

        context 'with system' do
          it 'request POST /applications/:id/histories with payload' do
            application.options = mock_application_history.except(:id, :application_id, :version)
              .merge(system: 'system_name').with_indifferent_access

            expect(application).to_not receive(:find_id_by).with(:project, :name, anything)
            expect(application).to receive(:find_id_by).with(:system, :name, 'system_name', project_id: nil)
            expect(application).to receive(:find_id_by).with(:application, :name, 'application_name', system_id: 1, project_id: nil)

            payload = application.options.except(:system)
            expect(application.connection).to receive(:post).with("/applications/#{mock_application[:id]}/histories", payload)
            application.release(mock_application[:name])
          end
        end

        context 'with project' do
          it 'request POST /applications/:id/histories with payload' do
            application.options = mock_application_history.except(:id, :application_id, :version)
              .merge(project: 'project_name').with_indifferent_access

            expect(application).to receive(:find_id_by).with(:project, :name, 'project_name')
            expect(application).to_not receive(:find_id_by).with(:system, :name, anything, anything)
            expect(application).to receive(:find_id_by).with(:application, :name, 'application_name', system_id: nil, project_id: 1)

            payload = application.options.except(:system)
            expect(application.connection).to receive(:post).with("/applications/#{mock_application[:id]}/histories", payload)
            application.release(mock_application[:name])
          end
        end

        context 'with project and system' do
          it 'request POST /applications/:id/histories with payload' do
            application.options = mock_application_history.except(:id, :application_id, :version)
              .merge(system: 'system_name', project: 'project_name').with_indifferent_access

            expect(application).to receive(:find_id_by).with(:project, :name, 'project_name')
            expect(application).to receive(:find_id_by).with(:system, :name, 'system_name', project_id: 1)
            expect(application).to receive(:find_id_by).with(:application, :name, 'application_name', system_id: 1, project_id: 1)

            payload = application.options.except(:system)
            expect(application.connection).to receive(:post).with("/applications/#{mock_application[:id]}/histories", payload)
            application.release(mock_application[:name])
          end
        end
      end

      describe '#deploy' do
        let(:mock_response) { double(status: 202, headers: [], body: JSON.dump(mock_deployment)) }
        before do
          allow(application.connection).to receive(:post).with("/applications/#{mock_application[:id]}/deploy", anything).and_return(mock_response)
        end

        it 'allow valid options' do
          allowed_options = [:version, :environment, :system, :project]
          expect(commands['deploy'].options.keys).to match_array(allowed_options)
        end

        it 'request POST /applications/:id/deploy with payload' do
          application.options = { 'version' => mock_application_history[:version],
                                  'environment' => 'environment_name' }
          payload = application.options.except('version', 'environment')
                    .merge('environment_id' => 1, 'application_history_id' => 1)
          expect(application.connection).to receive(:post).with("/applications/#{mock_application[:id]}/deploy", payload)
          application.deploy(mock_application[:name])
        end

        it 'display message and record details' do
          expect(application).to receive(:message)
          expect(application).to receive(:output).with(mock_response)
          application.deploy(mock_application[:name])
        end

        context 'with system' do
          it 'request POST /applications/:id/deploy with payload' do
            application.options = { version:  mock_application_history[:version],
                                    environment: 'environment_name',
                                    system: 'system_name' }.with_indifferent_access

            expect(application).to_not receive(:find_id_by).with(:project, :name, anything)
            expect(application).to receive(:find_id_by).with(:system, :name, 'system_name', project_id: nil)
            expect(application).to receive(:find_id_by).with(:application, :name, 'application_name', system_id: 1, project_id: nil)

            payload = application.options.except(:version, :environment, :system)
                      .merge('environment_id' => 1, 'application_history_id' => 1)

            expect(application.connection).to receive(:post).with("/applications/#{mock_application[:id]}/deploy", payload)
            application.deploy(mock_application[:name])
          end
        end

        context 'with project' do
          it 'request POST /applications/:id/deploy with payload' do
            application.options = { version:  mock_application_history[:version],
                                    environment: 'environment_name',
                                    project: 'project_name'
            }.with_indifferent_access

            expect(application).to receive(:find_id_by).with(:project, :name, 'project_name')
            expect(application).to_not receive(:find_id_by).with(:system, :name, anything, anything)
            expect(application).to receive(:find_id_by).with(:application, :name, 'application_name', system_id: nil, project_id: 1)

            payload = application.options.except(:version, :environment, :system, :project)
                      .merge('environment_id' => 1, 'application_history_id' => 1)

            expect(application.connection).to receive(:post).with("/applications/#{mock_application[:id]}/deploy", payload)
            application.deploy(mock_application[:name])
          end
        end

        context 'with project and system' do
          it 'request POST /applications/:id/deploy with payload' do
            application.options = { version:  mock_application_history[:version],
                                    environment: 'environment_name',
                                    system: 'system_name',
                                    project: 'project_name'
            }.with_indifferent_access

            expect(application).to receive(:find_id_by).with(:project, :name, 'project_name')
            expect(application).to receive(:find_id_by).with(:system, :name, 'system_name', project_id: 1)
            expect(application).to receive(:find_id_by).with(:application, :name, 'application_name', system_id: 1, project_id: 1)

            payload = application.options.except(:version, :environment, :system, :project)
                      .merge('environment_id' => 1, 'application_history_id' => 1)

            expect(application.connection).to receive(:post).with("/applications/#{mock_application[:id]}/deploy", payload)
            application.deploy(mock_application[:name])
          end
        end
      end
    end
  end
end
