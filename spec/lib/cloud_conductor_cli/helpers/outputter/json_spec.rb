module CloudConductorCli
  module Helpers
    module Outputter
      describe Json do
        before do
          @output = Json.new
          allow(@output).to receive(:puts)
        end

        describe '#output' do
          it 'display the given json string to standard output' do
            response = double(:respnose, body: '{ "dummy": "value" }')
            expect(@output).to receive(:puts).with('{ "dummy": "value" }')

            @output.output(response)
          end
        end
      end
    end
  end
end
