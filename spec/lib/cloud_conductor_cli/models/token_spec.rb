require 'active_support/core_ext'

module CloudConductorCli
  module Models
    describe Token do
      let(:token) { CloudConductorCli::Models::Token.new }
      let(:commands) { CloudConductorCli::Models::Token.commands }
      let(:mock_token) do
        {
          auth_token: "1ozvZ5BU1GMy5sMNrykq"
        }
      end

      before do
        allow(CloudConductorCli::Helpers::Connection).to receive(:new).and_return(double(get: true, post: true, put: true, delete: true, request: true))
        allow(token).to receive(:output)
        allow(token).to receive(:message)
      end

      describe '#get' do
        let(:mock_response) { double(status: 200, headers: [], body: JSON.dump([mock_token])) }
        before do
          allow(token.connection).to receive(:post).with('/tokens', anything).and_return(mock_response)
        end

        it 'allow valid options' do
          allowed_options = [:email,:password]
          expect(commands['get'].options.keys).to match_array(allowed_options)
        end

        it 'display record list' do
          expect(token).to receive(:output).with(mock_response)
          token.get
        end

        describe 'with email and password' do
          it 'request POST /tokens' do
            token.options = { email: 'test@example.com', password: 'password' }.with_indifferent_access
            payload = {
              'email' => 'test@example.com' ,
              'password' => 'password'
            }
            expect(token.connection).to receive(:post).with('/tokens', payload)
            token.get
          end
        end
      end
    end
  end
end
