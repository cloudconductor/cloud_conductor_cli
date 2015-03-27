module CloudConductorCli
  module Helpers
    describe Input do
      before do
        @input = Object.new
        @input.extend(Input)
      end

      describe '#input_template_parameters' do
        before do
          allow(@input).to receive(:template_parameters).and_return({})
          allow(@input).to receive(:read_user_inputs).and_return([])
        end

        it 'call template_parameters' do
          expect(@input).to receive(:template_parameters).with(['dummy_pattern_name']).and_return({})

          @input.input_template_parameters(['dummy_pattern_name'])
        end

        it 'call read_user_inputs' do
          expect(@input).to receive(:read_user_inputs).with({}).and_return([[]])

          @input.input_template_parameters(['dummy_pattern_name'])
        end
      end

      describe '#read_user_inputs' do
        before do
          allow(@input).to receive(:display_message)
          allow(@input).to receive(:validate_parameter).and_return(true)
          allow(Readline).to receive(:readline).and_return('dummy_input')

          @parameters = {
            'dummy_pattern_name' => {
              'dummy_params' => {
                'Description' => 'dummy_description',
                'Default' => 'dummy_default'
              }
            }
          }
        end

        it 'call display_message' do
          expect(@input).to receive(:display_message).with('Input dummy_pattern_name Parameters')
          expect(@input).to receive(:display_message).with('dummy_params: dummy_description', indent_level: 1)

          @input.read_user_inputs(@parameters)
        end

        it 'call validate_parameter' do
          options = { 'Description' => 'dummy_description', 'Default' => 'dummy_default' }
          expect(@input).to receive(:validate_parameter).with('dummy_input', options)

          @input.read_user_inputs(@parameters)
        end

        it 'does loop processing while validate_parameter is return false' do
          allow(@input).to receive(:validate_parameter).and_return(false, false, false, true)
          expect(@input).to receive(:validate_parameter).exactly(4).times

          @input.read_user_inputs(@parameters)
        end

        it 'call readline' do
          expect(Readline).to receive(:readline).with('  Default [dummy_default] > ')

          @input.read_user_inputs(@parameters)
        end

        it 'use input value if input value is not nil' do
          expected_result = {
            'dummy_pattern_name' => {
              'dummy_params' => 'dummy_input'
            }
          }

          results = @input.read_user_inputs(@parameters)
          expect(results).to eq(expected_result)
        end

        it 'use default value if input value is nil and default value is not nil' do
          allow(Readline).to receive(:readline).and_return(nil)
          expected_result = {
            'dummy_pattern_name' => {
              'dummy_params' => 'dummy_default'
            }
          }

          results = @input.read_user_inputs(@parameters)
          expect(results).to eq(expected_result)
        end

        it 'nil if input value is nil and  default value is nil' do
          allow(Readline).to receive(:readline).and_return(nil)

          parameters = {
            'dummy_pattern_name' => {
              'dummy_params' => {
                'Description' => 'dummy_description'
              }
            }
          }

          expected_result = {
            'dummy_pattern_name' => {
              'dummy_params' => nil
            }
          }

          results = @input.read_user_inputs(parameters)
          expect(results).to eq(expected_result)
        end

        it 'callexit when forced termination' do
          expect(@input).to receive(:exit)
          allow(Readline).to receive(:readline).and_raise(Interrupt)

          @input.read_user_inputs(@parameters)
        end
      end

      describe '#validate_parameter' do
        it 'returns true if type matched' do
          expect(@input.validate_parameter('string value', 'Type' => 'String')).to be_truthy
          expect(@input.validate_parameter('comma,delimited,list', 'Type' => 'CommaDelimitedList')).to be_truthy
          expect(@input.validate_parameter(Integer('2'), 'Type' => 'Number')).to be_truthy
        end

        it 'returns false if type mismatch' do
          expect(@input.validate_parameter('string value', 'Type' => 'Number')).to be_falsey
          expect(@input.validate_parameter('comma,delimited,list', 'Type' => 'Number')).to be_falsey
        end
      end
    end
  end
end
