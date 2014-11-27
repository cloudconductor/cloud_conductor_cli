require 'pry'

module CloudConductorCli
  module Helpers
    describe Input do
      before do
        @input = Object.new
        @input.extend(Input)
      end

      describe '#input_template_parameters' do
        before do
          @input.stub(:pattern_parameters).and_return({})
          @input.stub(:read_user_inputs).and_return([])
        end

        it 'call pattern_parameters' do
          @input.should_receive(:pattern_parameters).with(['dummy_pattern_name']).and_return({})

          @input.input_template_parameters(['dummy_pattern_name'])
        end

        it 'call read_user_inputs' do
          @input.should_receive(:read_user_inputs).with({}).and_return([[]])

          @input.input_template_parameters(['dummy_pattern_name'])
        end
      end

      describe '#read_user_inputs' do
        before do
          @input.stub(:display_message)
          @input.stub(:validate_parameter).and_return(true)
          Readline.stub(:readline).and_return('dummy_input')

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
          @input.should_receive(:display_message).with('Input dummy_pattern_name Parameters')
          @input.should_receive(:display_message).with('dummy_params: dummy_description', indent_level: 1)

          @input.read_user_inputs(@parameters)
        end

        it 'call validate_parameter' do
          options = { 'Description' => 'dummy_description', 'Default' => 'dummy_default' }
          @input.should_receive(:validate_parameter).with(options, 'dummy_input')

          @input.read_user_inputs(@parameters)
        end

        it 'does loop processing while validate_parameter is return false' do
          @input.stub(:validate_parameter).and_return(false, false, false, true)
          @input.should_receive(:validate_parameter).exactly(4).times

          @input.read_user_inputs(@parameters)
        end

        it 'call readline' do
          Readline.should_receive(:readline).with('  Default [dummy_default] > ')

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
          Readline.stub(:readline).and_return(nil)
          expected_result = {
            'dummy_pattern_name' => {
              'dummy_params' => 'dummy_default'
            }
          }

          results = @input.read_user_inputs(@parameters)
          expect(results).to eq(expected_result)
        end

        it 'nil if input value is nil and  default value is nil' do
          Readline.stub(:readline).and_return(nil)

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
      end
    end
  end
end
