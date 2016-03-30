module CloudConductorCli
  module Helpers
    describe Input do
      before do
        @input = Object.new
        @input.extend(Input)
        allow(@input).to receive(:puts)
        allow(Readline).to receive(:readline)
      end

      describe '#input_template_parameters' do
        before do
          allow(@input).to receive(:template_parameters).and_return({})
          allow(@input).to receive(:read_user_inputs).and_return([])
        end

        it 'call template_parameters' do
          expect(@input).to receive(:template_parameters).with('dummy_pattern_name', 1, '1').and_return({})

          @input.input_template_parameters('dummy_pattern_name', 1, '1')
        end

        it 'call read_user_inputs' do
          expect(@input).to receive(:read_user_inputs).with({}).and_return([[]])

          @input.input_template_parameters('dummy_pattern_name', 1, '1')
        end
      end

      describe '#read_user_inputs' do
        before do
          allow(@input).to receive(:read_single_parameter).and_return(type: 'static', value: 'dummy_value')

          @parameters = {
            'dummy_pattern_name' => {
              'cloud_formation' => {
                'DummyParam1' => {
                  'Description' => 'dummy_description1',
                  'Default' => 'dummy_default1'
                },
                'DummyParam2' => {
                  'Description' => 'dummy_description2',
                  'Default' => 'dummy_default2'
                }
              },
              'terraform' => {
                'aws' => {
                  'dummy_params3' => {
                    'description' => 'dummy_description3',
                    'default' => 'dummy_default3'
                  }
                },
                'openstack' => {
                  'dummy_params3' => {
                    'description' => 'dummy_description3',
                    'default' => 'dummy_default3'
                  }
                }
              }
            }
          }
        end

        it 'call puts with Pattern name' do
          expect(@input).to receive(:puts).with('Input dummy_pattern_name Parameters')

          @input.read_user_inputs(@parameters)
        end

        it 'call #read_single_parameter with each variable' do
          options1 = { description: 'dummy_description1', default: 'dummy_default1' }
          expect(@input).to receive(:read_single_parameter).with('DummyParam1', options1)

          options2 = { description: 'dummy_description2', default: 'dummy_default2' }
          expect(@input).to receive(:read_single_parameter).with('DummyParam2', options2)

          options3 = { description: 'dummy_description3', default: 'dummy_default3' }
          expect(@input).to receive(:read_single_parameter).with('dummy_params3', options3)

          @input.read_user_inputs(@parameters)
        end

        it 'collapse variable which has same key in terraform variables' do
          options3 = { description: 'dummy_description3', default: 'dummy_default3' }
          expect(@input).to receive(:read_single_parameter).with('dummy_params3', options3).once

          @input.read_user_inputs(@parameters)
        end

        it 'return user specified variables' do
          expect(@input.read_user_inputs(@parameters)).to eq(
            'dummy_pattern_name' => {
              'cloud_formation' => {
                'DummyParam1' => {
                  type: 'static',
                  value: 'dummy_value'
                },
                'DummyParam2' => {
                  type: 'static',
                  value: 'dummy_value'
                }
              },
              'terraform' => {
                'aws' => {
                  'dummy_params3' => {
                    type: 'static',
                    value: 'dummy_value'
                  }
                },
                'openstack' => {
                  'dummy_params3' => {
                    type: 'static',
                    value: 'dummy_value'
                  }
                }
              }
            }
          )
        end

        it 'call exit to terminate forcedly when intrrupted' do
          expect(@input).to receive(:exit)
          allow(@input).to receive(:read_single_parameter).and_raise(Interrupt)

          @input.read_user_inputs(@parameters)
        end
      end

      describe '#read_single_parameter' do
        before do
          allow(@input).to receive(:validate_parameter).and_return(true)
          @options = { description: 'dummy_description', default: 'dummy_default' }
        end

        it 'indicate key name and description' do
          expect(@input).to receive(:puts).with('  dummy_param: dummy_description')

          @input.send(:read_single_parameter, 'dummy_param', @options)
        end

        it 'call Readline.readline to input type and value' do
          expect(Readline).to receive(:readline).with('  Type(static, module) > ')
          expect(Readline).to receive(:readline).with('  Default [dummy_default] > ')

          @input.send(:read_single_parameter, 'dummy_param', @options)
        end

        it 'does loop processing while input invalid type' do
          expect(Readline).to receive(:readline).with('  Type(static, module) > ').exactly(3).times
          expect(Readline).to receive(:readline).with('  Default [dummy_default] > ').once
          allow(Readline).to receive(:readline).and_return('aaa', 'dummy', 'module', 'value')

          @input.send(:read_single_parameter, 'dummy_param', @options)
        end

        it 'does loop processing while validate_parameter return false' do
          allow(@input).to receive(:validate_parameter).and_return(false, false, false, true)
          expect(Readline).to receive(:readline).with('  Default [dummy_default] > ').exactly(4).times
          expect(@input).to receive(:validate_parameter).exactly(4).times

          @input.send(:read_single_parameter, 'dummy_param', @options)
        end

        it 'return hash that contains type and value which is inputted by user' do
          allow(Readline).to receive(:readline).and_return('static', 'dummy_value')
          expect(@input.send(:read_single_parameter, 'dummy_param', @options)).to eq(type: 'static', value: 'dummy_value')
        end

        it 'return default value when user has skipped' do
          allow(Readline).to receive(:readline).and_return('module', '')
          expect(@input.send(:read_single_parameter, 'dummy_param', @options)).to eq(type: 'module', value: 'dummy_default')
        end
      end

      describe '#validate_parameter' do
        it 'returns true if type matched' do
          expect(@input.validate_parameter('string value', type: 'String')).to be_truthy
          expect(@input.validate_parameter('comma,delimited,list', type: 'CommaDelimitedList')).to be_truthy
          expect(@input.validate_parameter('2', type: 'Number')).to be_truthy
        end

        it 'returns false if input text is blank' do
          expect(@input.validate_parameter('', type: 'String')).to be_falsey
          expect(@input.validate_parameter(nil, type: 'String')).to be_falsey
        end

        it 'returns false if type mismatch' do
          expect(@input.validate_parameter('string value', type: 'Number')).to be_falsey
          expect(@input.validate_parameter('comma,delimited,list', type: 'Number')).to be_falsey
        end
      end

      describe '#unify_options' do
        it 'return unified options' do
          options = {
            'Description' => 'dummy_description',
            'Default' => 'dummy_default',
            'Type' => 'Number'
          }

          expect(@input.send(:unify_options, options)).to eq(
            description: 'dummy_description',
            default: 'dummy_default',
            type: 'Number'
          )
        end
      end
    end
  end
end
