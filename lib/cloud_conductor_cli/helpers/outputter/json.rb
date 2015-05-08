module CloudConductorCli
  module Helpers
    module Outputter
      class Json
        def output(response)
          puts response.body
        end

        def message(_message)
        end
      end
    end
  end
end
