require 'thor'

module CloudConductorCli
  module Models
    class Token < Thor
      include Models::Base

      desc 'get', 'Get token'
      method_option :email, type: :string, desc: 'Account email. use CC_AUTH_ID environment if not specified.'
      method_option :password, type: :string, desc: 'Account password. use CC_AUTH_PASSWORD environment if not specified.'

      def get
        payload = declared(options, self.class, :get)
        payload = payload.merge('email' => ENV['CC_AUTH_ID'])
        payload = payload.merge('password' => ENV['CC_AUTH_PASSWORD'])
        response = connection.post('/tokens', payload)
        output(response)
      end
    end
  end
end
