module CloudConductorCli
  module Helpers
    module Outputter
      class Json
        def output(response)
          puts response.body
        end
      end
    end
  end
end
