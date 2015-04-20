module CloudConductorCli
  module Helpers
    module Output
      class Json
        def output(response)
          puts response.body
        end
      end
    end
  end
end
