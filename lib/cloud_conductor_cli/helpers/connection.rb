require 'faraday'
require 'rack'

module CloudConductorCli
  module Helpers
    class Connection
      include Helpers::Outputter
      attr_reader :faraday, :api_prefix, :auth_token

      def initialize(host = nil, port = nil, auth_id = nil, auth_password = nil)
        cc_host = host || ENV['CC_HOST']
        cc_port = port || ENV['CC_PORT'] || 80
        auth_id ||= ENV['CC_AUTH_ID']
        auth_password ||= ENV['CC_AUTH_PASSWORD']
        if cc_host.nil?
          error_exit('No value specified for CloudConductor server host. ' \
                     'This command required --host option or CC_HOST environment variable.')
        end
        if auth_id.nil? || auth_password.nil?
          error_exit('No value specified for CloudConductor auth_id or auth_password. ' \
                     'This command required CC_AUTH_ID and CC_AUTH_PASSWORD environment variable.')
        end
        server_url = "http://#{cc_host}:#{cc_port}/"
        @api_prefix = '/api/v1'
        begin
          default_headers = {
            'User-Agent' => "CloudConductor CLI v#{VERSION}",
            'Accept' => 'application/json'
          }
          @faraday = Faraday.new(url: server_url, headers: default_headers) do |builder|
            builder.request :url_encoded
            builder.adapter :net_http
          end
        rescue URI::InvalidURIError => e
          error_exit("Invalid URL. #{e.message}")
        end
        @auth_token = get_auth_token(auth_id, auth_password)
      end

      def get(path, payload = {})
        request(:get, path, payload)
      end

      def post(path, payload = {})
        request(:post, path, payload)
      end

      def put(path, payload = {})
        request(:put, path, payload)
      end

      def delete(path)
        request(:delete, path)
      end

      def request(method, path, payload = {})
        request_path = File.join(api_prefix, path)
        payload = payload.select { |_key, value| !value.nil? }
        payload.merge!(auth_token: auth_token) if auth_token
        begin
          response = faraday.send(method, request_path, payload)
        rescue Faraday::ConnectionFailed
          error_exit("Failed to connect #{faraday.url_prefix}.")
        rescue => e
          error_exit("UnexpectedError: #{e.class} #{e.message}.")
        end
        unless response.success?
          begin
            error_message = JSON.parse(response.body)['error']
          rescue JSON::ParserError
            error_message = nil
          end
          status_message = Rack::Utils::HTTP_STATUS_CODES[response.status]
          error_exit("#{method.upcase} #{request_path} returns #{response.status} #{status_message}. #{error_message}")
        end
        response
      end

      private

      def get_auth_token(auth_id, auth_password)
        payload = {
          email: auth_id,
          password: auth_password
        }
        response = post('/tokens', payload)
        JSON.parse(response.body)['auth_token']
      end
    end
  end
end
