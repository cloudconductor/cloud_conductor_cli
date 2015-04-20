module CloudConductorCli
  module Helpers
    describe Output do
      before do
        @output = Object.new
        @output.extend(Output)
        allow(@output).to receive(:puts)
      end

      describe '#display_message' do
        it 'display the given message to standard output' do
          expect(@output).to receive(:puts).with('dummy message')

          @output.send(:display_message, 'dummy message')
        end

        it 'display the given message to standard output' do
          expect(@output).to receive(:puts).with('  dummy message')

          @output.send(:display_message, 'dummy message', indent_level: 1)
        end

        it 'display the given message to standard output' do
          expect(@output).to receive(:puts).with('    dummy message')

          @output.send(:display_message, 'dummy message', indent_level: 1, indent_spaces: 4)
        end
      end

      describe '#error_exit' do
        before do
          allow(@output).to receive(:warn)
          allow(@output).to receive(:exit)
        end

        it 'call warn with message' do
          expect(@output).to receive(:warn).with('Error: dummy message')

          @output.error_exit('dummy message')
        end

        it 'call warn with message of response body' do
          expect(@output).to receive(:warn).with('dummy response')

          response = double(:response, body: '{ "message": "dummy response"}')
          @output.error_exit('dummy message', response)
        end

        it 'call warn with plain body if response body is invalid JSON string' do
          expect(@output).to receive(:warn).with('dummy error response')

          response = double(:response, body: 'dummy error response')
          @output.error_exit('dummy message', response)
        end

        it 'exit with specified exit_code' do
          expect(@output).to receive(:exit).with(2)

          @output.error_exit('dummy message', nil, 2)
        end
      end

      describe '#normal_exit' do
        before do
          allow(@output).to receive(:display_message)
          allow(@output).to receive(:exit)
        end

        it 'display the passed message on the screen' do
          expect(@output).to receive(:puts).with('dummy message')

          @output.normal_exit('dummy message')
        end

        it 'exit with specified exit_code' do
          expect(@output).to receive(:exit).with(1)

          @output.normal_exit('dummy message', 1)
        end
      end
    end
  end
end
