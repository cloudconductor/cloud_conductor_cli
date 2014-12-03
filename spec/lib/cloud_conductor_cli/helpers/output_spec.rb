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

          @output.display_message('dummy message')
        end

        it 'display the given message to standard output' do
          expect(@output).to receive(:puts).with('  dummy message')

          @output.display_message('dummy message', indent_level: 1)
        end

        it 'display the given message to standard output' do
          expect(@output).to receive(:puts).with('    dummy message')

          @output.display_message('dummy message', indent_level: 1, indent_spaces: 4)
        end
      end

      describe '#display_list' do
        before do
          allow(@output).to receive(:display_message)
          allow(@output).to receive(:filter) { |data, _exclude_keys| data }
          allow(Formatador).to receive(:display_compact_table)
        end

        it 'call filter if exclude_keys is not empty' do
          expect(@output).to receive(:filter).with([dummy_key: 'dummy_data'], ['dummy_key'])

          @output.display_list([dummy_key: 'dummy_data'], exclude_keys: ['dummy_key'])
        end

        it 'call display_message if display_data is empty' do
          expect(@output).to receive(:display_message).with('No records')

          @output.display_list []
        end

        it 'call Formatador#display_compact_table if display_data is not empty' do
          expect(Formatador).to receive(:display_compact_table).with([dummy_key: 'dummy_data'], [:dummy_key])

          @output.display_list [dummy_key: 'dummy_data']
        end
      end

      describe '#display_details' do
        before do
          allow(@output).to receive(:filter) { |data, _exclude_keys| data }
          allow(@output).to receive(:verticalize) { |data, _exclude_keys| data }
          allow(Formatador).to receive(:display_compact_table)
        end

        it 'call filter' do
          expect(@output).to receive(:filter).with({ dummy_key: 'dummy_data' }, [:dummy_key])

          @output.display_details({ dummy_key: 'dummy_data' }, exclude_keys: [:dummy_key])
        end

        it 'call verticalize' do
          expect(@output).to receive(:verticalize).with(dummy_key: 'dummy_data')

          @output.display_details({ dummy_key: 'dummy_data' }, exclude_keys: [:dummy_key])
        end

        it 'call display_compact_table' do
          expect(Formatador).to receive(:display_compact_table).with(dummy_key: 'dummy_data')

          @output.display_details({ dummy_key: 'dummy_data' }, exclude_keys: [:dummy_key])
        end
      end

      describe '#verticalize' do
        it 'return arg if data is not hash' do
          expect(@output.verticalize('dummy')).to eq('dummy')
        end

        it 'return hash that divided the data to key and value' do
          expected_data = {
            property: 'dummy_key',
            value: 'dummy_value'
          }
          expect(@output.verticalize('dummy_key' => 'dummy_value')).to eq([expected_data])
        end
      end

      describe '#filter' do
        before do
        end

        it 'return array of hash that deleted the key that is included in the exclude_keys' do
          data = [{ id: 1, name: 'dummy_name1' }, { id: 2, name: 'dummy_name2' }]
          filtered_data = @output.filter(data, [:name])

          expect(filtered_data).to eq([{ id: 1 }, { id: 2 }])
        end

        it 'return hash that deleted the key that is included in the exclude_keys' do
          data = { id: 1, name: 'dummy_name1' }
          filtered_data = @output.filter(data, [:name])

          expect(filtered_data).to eq(id: 1)
        end

        it 'return data that have not changed' do
          data = 'dummy_data'
          filtered_data = @output.filter(data, [:name])

          expect(filtered_data).to eq('dummy_data')
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
          expect(@output).to receive(:display_message).with('dummy message')

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
