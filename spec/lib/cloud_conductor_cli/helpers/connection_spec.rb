require 'pry'
require 'faraday'

module CloudConductorCli
  module Helpers
    describe Connection do
      before do
        @stubs  = Faraday::Adapter::Test::Stubs.new

        original_method = Faraday.method(:new)
        Faraday.stub(:new) do |*args, &block|
          original_method.call(*args) do |builder|
            builder.adapter :test, @stubs
            yield block if block_given?
          end
        end

        @connection = Connection.new('127.0.0.1', 9999)
        Connection.any_instance.stub(:error_exit)
      end

      describe '#initialize' do
        it 'call error_exit if host does not spacified by argument and environment variables' do
          Connection.any_instance.should_receive(:error_exit)

          ENV['CC_HOST'] = nil
          Connection.new(nil)
        end

        it 'create url from environment variables' do
          ENV['CC_HOST'] = 'localhost'
          ENV['CC_PORT'] = '10000'
          connection = Connection.new(nil)
          url = connection.instance_variable_get('@cc_url')

          expect(url).to eq('http://localhost:10000/')
        end

        it 'create url from arguments' do
          ENV['CC_HOST'] = 'localhost'
          ENV['CC_PORT'] = '10000'
          connection = Connection.new('127.0.0.1', 9999)
          url = connection.instance_variable_get('@cc_url')

          expect(url).to eq('http://127.0.0.1:9999/')
        end

        it 'instanciate Faraday with url and headers' do
          Faraday.should_receive(:new).with(url: 'http://127.0.0.1:9999/', headers: kind_of(Hash))

          Connection.new('127.0.0.1', 9999)
        end

        it 'call error_exit if url is invalid' do
          Connection.any_instance.should_receive(:error_exit)
          Faraday.stub(:new).and_raise(URI::InvalidURIError)

          Connection.new('127.0.0.1', 9999)
        end

        it 'keep instance of Faraday::Connection' do
          Faraday.unstub(:new)
          connection = Connection.new('127.0.0.1', 9999)
          faraday = connection.instance_variable_get('@faraday')

          expect(faraday).to be_is_a(Faraday::Connection)
        end
      end

      describe 'get' do
        it 'call CloudConductor GET API through request method' do
          @connection.should_receive(:request).with(:get, '/dummy/get/path')

          @connection.get '/dummy/get/path'
        end
      end

      describe 'post' do
        it 'call CloudConductor POST API through request method' do
          @connection.should_receive(:request).with(:post, '/dummy/post/path', dummy_key: 'dummy_name')

          @connection.post('/dummy/post/path', dummy_key: 'dummy_name')
        end
      end

      describe 'put' do
        it 'call CloudConductor PUT API through request method' do
          @connection.should_receive(:request).with(:put, '/dummy/put/path', dummy_key: 'dummy_name')

          @connection.put('/dummy/put/path', dummy_key: 'dummy_name')
        end
      end

      describe 'delete' do
        it 'call CloudConductor DELETE API through request method' do
          @connection.should_receive(:request).with(:delete, '/dummy/delete/path')

          @connection.delete '/dummy/delete/path'
        end
      end

      describe 'request' do
        it 'call error_exit if raise faraday connection failed' do
          @stubs.get('/dummy/get/path') { fail Faraday::ConnectionFailed, 'Dummy Fail' }
          @connection.should_receive(:error_exit).with('Failed to connect http://127.0.0.1:9999/.')

          @connection.request(:get, '/dummy/get/path')
        end

        it 'call error_exit if raise other error' do
          @stubs.get('/dummy/get/path') { fail 'Dummy Fail' }
          @connection.should_receive(:error_exit).with('UnexpectedError: RuntimeError Dummy Fail.')

          @connection.request(:get, '/dummy/get/path')
        end

        it 'return response' do
          @stubs.get('/dummy/get/path') { [200, {}, 'Dummy Response'] }

          response = @connection.request(:get, '/dummy/get/path')
          expect(response).to be_is_a(Faraday::Response)
          expect(response.status).to eq(200)
          expect(response.body).to eq('Dummy Response')
        end
      end
    end
  end
end
