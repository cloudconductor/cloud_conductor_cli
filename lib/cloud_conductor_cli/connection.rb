require 'faraday'

module CloudConductorCli
  class Connection
    include Base

    def initialize(host, port = nil)
      cc_host = host || ENV['CC_HOST']
      cc_port = port || ENV['CC_PORT'] || 80
      if cc_host.nil?
        error_exit('No value specified for CloudConductor server host. ' \
                   'This command required --host option or CC_HOST environment.')
      end
      @cc_url = "http://#{cc_host}:#{cc_port}/"
      begin
        default_headers = {
          'User-Agent' => "CloudConductor CLI v#{VERSION}",
          'Accept' => 'application/json'
        }
        @connection = Faraday.new(url: @cc_url, headers: default_headers) do |builder|
          builder.request :url_encoded
          builder.adapter :net_http
        end
      rescue URI::InvalidURIError => e
        error_exit("Invalid URL. #{e.message}")
      end
    end

    def get(path)
      request(:get, path)
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
      begin
        response = @connection.send(method, path, payload)
      rescue Faraday::ConnectionFailed
        error_exit("Failed to connect #{@cc_url}.")
      rescue => e
        error_exit("UnexpectedError: #{e.class} #{e.message}.")
      end
      response
    end
  end
end
