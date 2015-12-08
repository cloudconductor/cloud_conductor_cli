require 'faraday'

module CloudConductorCli
  module Helpers
    describe Connection do
      let(:connection) { Connection.new }

      before do
        allow(ENV).to receive(:[]).with('CC_HOST').and_return('127.0.0.1')
        allow(ENV).to receive(:[]).with('CC_PORT').and_return(3000)
        allow(ENV).to receive(:[]).with('CC_AUTH_ID').and_return('test@example.com')
        allow(ENV).to receive(:[]).with('CC_AUTH_PASSWORD').and_return('password')
        allow(ENV).to receive(:[]).with('http_proxy').and_return(nil)
        allow_any_instance_of(Connection).to receive(:get_auth_token).and_return('some_auth_token')
        allow_any_instance_of(Connection).to receive(:error_exit).and_raise(SystemExit)
      end

      describe '#initialize' do
        context 'without environment variables' do
          it 'error_exit when called without valid host' do
            allow(ENV).to receive(:[]).with('CC_HOST').and_return(nil)
            allow(ENV).to receive(:[]).with('CC_PORT').and_return(nil)
            expect_any_instance_of(Connection).to receive(:error_exit).with(String)
            expect { Connection.new }.to raise_error(SystemExit)
          end

          it 'error_exit when called without CC_AUTH_ID environment variable' do
            allow(ENV).to receive(:[]).with('CC_AUTH_ID').and_return(nil)
            expect_any_instance_of(Connection).to receive(:error_exit)
            expect { Connection.new }.to raise_error(SystemExit)
          end

          it 'error_exit when called without CC_AUTH_PASSWORD environment variable' do
            allow(ENV).to receive(:[]).with('CC_AUTH_PASSWORD').and_return(nil)
            expect_any_instance_of(Connection).to receive(:error_exit)
            expect { Connection.new }.to raise_error(SystemExit)
          end

          it 'success when called with valid host' do
            new_connection = Connection.new('127.0.0.1', 3000)
            expect(new_connection.faraday.url_prefix.to_s).to eq('http://127.0.0.1:3000/')
            expect(new_connection.api_prefix).to eq('/api/v1')
            expect(new_connection.auth_token).not_to be_empty
          end
        end

        context 'with environment variables' do
          it 'success when called without valid host' do
            new_connection = Connection.new
            expect(new_connection.faraday.url_prefix.to_s).to eq('http://127.0.0.1:3000/')
            expect(new_connection.api_prefix).to eq('/api/v1')
            expect(new_connection.auth_token).not_to be_empty
          end

          it 'success and use specified host when called with host' do
            new_connection = Connection.new('localhost', 4000)
            expect(new_connection.faraday.url_prefix.to_s).to eq('http://localhost:4000/')
            expect(new_connection.api_prefix).to eq('/api/v1')
            expect(new_connection.auth_token).not_to be_empty
          end
        end
      end

      describe '#get' do
        it 'call request with :get' do
          path = '/path'
          payload = {}
          expect(connection).to receive(:request).with(:get, path, payload)
          connection.get(path)
        end
      end

      describe '#post' do
        it 'call request with :post' do
          path = '/path'
          payload = {}
          expect(connection).to receive(:request).with(:post, path, payload)
          connection.post(path, payload)
        end
      end

      describe '#put' do
        it 'call request with :put' do
          path = '/path'
          payload = {}
          expect(connection).to receive(:request).with(:put, path, payload)
          connection.put(path, payload)
        end
      end

      describe '#delete' do
        it 'call request with :delete' do
          path = '/path'
          expect(connection).to receive(:request).with(:delete, path)
          connection.delete(path)
        end
      end

      describe '#request' do
        before do
          allow(connection.faraday).to receive(:get).and_return(double(status: 200, body: '{}', success?: true))
          allow(connection.faraday).to receive(:post).and_return(double(status: 201, body: '{}', success?: true))
          allow(connection.faraday).to receive(:put).and_return(double(status: 200, body: '{}', success?: true))
          allow(connection.faraday).to receive(:delete).and_return(double(status: 204, body: nil, success?: true))
        end

        it 'send request to path with auth_token' do
          path = '/path'
          payload = {}
          expected_path = File.join(connection.api_prefix, path)
          expected_payload = payload.merge(auth_token: connection.auth_token)
          [:get, :post, :put, :delete].each do |method|
            expect(connection.faraday).to receive(method).with(expected_path, expected_payload)
            connection.request(method, path, payload)
          end
        end

        it 'returns Faraday::Response' do
          expect(connection).to receive(:request).and_return(duck_type(:status, :body, :success?))
          connection.request(:get, '/path', {})
        end

        it 'error_exit when connection failed' do
          allow(connection.faraday).to receive(:get) { fail Faraday::ConnectionFailed }
          expect(connection).to receive(:error_exit).and_raise(SystemExit)
          expect { connection.request(:get, '/path', {}) }.to raise_error(SystemExit)
        end

        it 'error_exit with status code message unless request success' do
          allow(connection.faraday).to receive(:send).with(:get, any_args).and_return(double(status: 500, body: '{"error": "error message"}', success?: false))
          expect(connection).to receive(:error_exit).and_raise(SystemExit)
          expect { connection.request(:get, '/path', {}) }.to raise_error(SystemExit)
        end
      end
    end
  end
end
