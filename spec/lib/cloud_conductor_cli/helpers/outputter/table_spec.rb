module CloudConductorCli
  module Helpers
    module Outputter
      describe Table do
        before do
          @output = Table.new
          allow(@output).to receive(:puts)
          allow(@output).to receive(:warn)
        end

        describe '#output' do
          it 'call display_list when passed Array as JSON' do
            response = double(:respnose, body: '["dummy1", "dummy2"]')
            expect(@output).to receive(:display_list).with(%w(dummy1 dummy2))

            @output.output(response)
          end

          it 'call display_detail when passed Hash as JSON' do
            response = double(:respnose, body: '{ "dummy": "value" }')
            expect(@output).to receive(:display_detail).with('dummy' => 'value')

            @output.output(response)
          end

          it 'exit with exit status when passed JSON is invalid to parse' do
            response = double(:respnose, body: '{')
            expect(@output).to receive(:exit).with(1)

            @output.output(response)
          end
        end

        describe '#display_list' do
          before do
            allow(@output).to receive(:message)
            allow(@output).to receive(:filter) { |data, _exclude_keys| data }
            allow(Formatador).to receive(:display_compact_table)
          end

          it 'call filter if exclude_keys is not empty' do
            expect(@output).to receive(:filter).with([dummy_key: 'dummy_data'], ['dummy_key'])

            @output.send(:display_list, [dummy_key: 'dummy_data'], exclude_keys: ['dummy_key'])
          end

          it 'call message if display_data is empty' do
            expect(@output).to receive(:message).with('No records')

            @output.send(:display_list, [])
          end

          it 'call Formatador#display_compact_table if display_data is not empty' do
            expect(Formatador).to receive(:display_compact_table).with([dummy_key: 'dummy_data'], [:dummy_key])

            @output.send(:display_list, [dummy_key: 'dummy_data'])
          end
        end

        describe '#display_detail' do
          before do
            allow(@output).to receive(:filter) { |data, _exclude_keys| data }
            allow(@output).to receive(:verticalize) { |data, _exclude_keys| data }
            allow(Formatador).to receive(:display_compact_table)
          end

          it 'call filter' do
            expect(@output).to receive(:filter).with({ dummy_key: 'dummy_data' }, [:dummy_key])

            @output.send(:display_detail, { dummy_key: 'dummy_data' }, exclude_keys: [:dummy_key])
          end

          it 'call verticalize' do
            expect(@output).to receive(:verticalize).with(dummy_key: 'dummy_data')

            @output.send(:display_detail, { dummy_key: 'dummy_data' }, exclude_keys: [:dummy_key])
          end

          it 'call display_compact_table' do
            expect(Formatador).to receive(:display_compact_table).with(dummy_key: 'dummy_data')

            @output.send(:display_detail, { dummy_key: 'dummy_data' }, exclude_keys: [:dummy_key])
          end
        end

        describe '#message' do
          it 'display the given message to standard output' do
            expect(@output).to receive(:puts).with('dummy message')

            @output.send(:message, 'dummy message')
          end
        end

        describe '#verticalize' do
          it 'return arg if data is not hash' do
            expect(@output.send(:verticalize, 'dummy')).to eq('dummy')
          end

          it 'return hash that divided the data to key and value' do
            expected_data = {
              property: 'dummy_key',
              value: 'dummy_value'
            }
            expect(@output.send(:verticalize, 'dummy_key' => 'dummy_value')).to eq([expected_data])
          end
        end

        describe '#filter' do
          before do
          end

          it 'return array of hash that deleted the key that is included in the exclude_keys' do
            data = [{ id: 1, name: 'dummy_name1' }, { id: 2, name: 'dummy_name2' }]
            filtered_data = @output.send(:filter, data, [:name])

            expect(filtered_data).to eq([{ id: 1 }, { id: 2 }])
          end

          it 'return hash that deleted the key that is included in the exclude_keys' do
            data = { id: 1, name: 'dummy_name1' }
            filtered_data = @output.send(:filter, data, [:name])

            expect(filtered_data).to eq(id: 1)
          end

          it 'return data that have not changed' do
            data = 'dummy_data'
            filtered_data = @output.send(:filter, data, [:name])

            expect(filtered_data).to eq('dummy_data')
          end
        end
      end
    end
  end
end
