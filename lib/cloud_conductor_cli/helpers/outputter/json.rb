module CloudConductorCli
  module Helpers
    module Outputter
      class Json
        def output(response)
          puts response.body
        end

        def display_message(_message, _options)
        end
      end
    end
  end
end
