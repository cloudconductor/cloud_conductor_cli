require 'thor'

module CloudConductorCli
  module Models
    class Token < Thor
      include Models::Base

      desc 'get', 'Get token'
      method_option :email, type: :string, required: false, default: ENV['CC_AUTH_ID'], desc: 'Account email'
      method_option :password, type: :string, required: false,default: ENV['CC_AUTH_PASSWORD'],desc: 'Account password'

      def get
        payload = declared(options, self.class, :get)
        response = connection.post("/tokens", payload)
        output(response)
      end
    end
  end
end
