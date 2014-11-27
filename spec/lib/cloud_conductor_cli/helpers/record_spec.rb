module CloudConductorCli
  module Helpers
    describe Record do
      before do
        @record = Object.new
        @record.extend(Record)

        @options = { host: 'localhost', port: 9292 }
        @record.stub(:options).and_return(@options)
      end

      describe '#connection' do
        it 'call Connection new methods' do
          Connection.should_receive(:new).with('localhost', 9292)
          @record.connection
        end

        it 'returns Connection' do
          expect(@record.connection).to be_is_a(CloudConductorCli::Helpers::Connection)
        end
      end

      describe '#list_records' do
        before do
          response = double(:response, body: '{ "dummy_key": "dummy_value" }')
          @record.stub_chain(:connection, :get).and_return(response)
        end

        it 'call connection if parent_model is not nil' do
          @record.connection.should_receive(:get).with('/systems/1/applications')

          @record.list_records(:application, parent_model: :system, parent_id: 1)
        end

        it 'call connection if parent_model is nil' do
          @record.connection.should_receive(:get).with('/clouds')

          @record.list_records(:cloud)
        end

        it 'return hash that parse response body' do
          expect(@record.list_records(:cloud)).to eq('dummy_key' => 'dummy_value')
        end
      end

      describe '#find_id_by_name' do
        before do
          records = [{ 'id' => 1, 'name' => 'dummy_name' }, { 'id' => 2 }]
          @record.stub(:list_records).and_return(records)
        end

        it 'call list_records' do
          @record.should_receive(:list_records).with(:cloud, parent_model: nil, parent_id: nil)

          @record.find_id_by_name(:cloud, 'dummy_name')
        end

        it 'return record id that find by record name' do
          expect(@record.find_id_by_name(:cloud, 'dummy_name')).to eq(1)
        end

        it 'return record id that find by record id' do
          expect(@record.find_id_by_name(:cloud, 2)).to eq(2)
        end

        it 'return nil if does not find record' do
          expect(@record.find_id_by_name(:cloud, 3)).to eq(nil)
        end
      end

      describe '#select_by_names' do
        before do
          records = [{ 'id' => 1, 'name' => 'dummy_name1' }, { 'id' => 2, 'name' => 'dummy_name2' }]
          @record.stub(:list_records).and_return(records)
        end

        it 'call list_records' do
          @record.should_receive(:list_records)

          @record.select_by_names(:cloud, ['dummy_name1'])
        end

        it 'return record that select by record name' do
          expect(@record.select_by_names(:cloud, ['dummy_name1'])).to eq([{ 'id' => 1, 'name' => 'dummy_name1' }])
        end

        it 'return record that select by record id' do
          expect(@record.select_by_names(:cloud, ['2'])).to eq([{ 'id' => 2, 'name' => 'dummy_name2' }])
        end

        it 'return records that select by record name and record id' do
          records = @record.select_by_names(:clouds, %w(1 2 3))

          expect(records.size).to eq(2)
          expect(records[0]).to eq('id' => 1, 'name' => 'dummy_name1')
          expect(records[1]).to eq('id' => 2, 'name' => 'dummy_name2')
        end

        it 'return empty array if does not find record' do
          expect(@record.select_by_names(:cloud, ['test_name'])).to eq([])
        end
      end

      describe '#pattern_parameters' do
        before do
          @pattern_names = ['dummy_pattern_1']
          @record.stub(:find_id_by_name).with(:pattern, 'dummy_pattern_1').and_return(1)
          @record.stub(:find_id_by_name).with(:pattern, 'dummy_pattern_2').and_return(nil)
          @record.stub(:find_id_by_name).with(:pattern, 'dummy_pattern_3').and_return(3)

          response1 = double(:response, body: '{ "dummy_key": "dummy_value_1" }')
          response2 = double(:response, body: '{ "dummy_key": "dummy_value_3" }')
          @record.stub_chain(:connection, :get).with('/patterns/1/parameters').and_return(response1)
          @record.stub_chain(:connection, :get).with('/patterns/3/parameters').and_return(response2)
        end

        it 'call find_id_by_name' do
          @record.should_receive(:find_id_by_name).with(:pattern, 'dummy_pattern_1')

          @record.pattern_parameters @pattern_names
        end

        it 'call connection get ' do
          @record.connection.should_receive(:get).with('/patterns/1/parameters')

          @record.pattern_parameters @pattern_names
        end

        it 'return parameters that parse response body' do
          expect(@record.pattern_parameters @pattern_names).to eq('dummy_pattern_1' => { 'dummy_key' => 'dummy_value_1' })
        end

        it 'skip if pattern id is nil' do
          results = @record.pattern_parameters %w(dummy_pattern_1 dummy_pattern_2 dummy_pattern_3)

          expect(results.size).to eq(2)
          expect(results['dummy_pattern_1']).to eq('dummy_key' => 'dummy_value_1')
          expect(results['dummy_pattern_3']).to eq('dummy_key' => 'dummy_value_3')
        end
      end

      describe '#validate_parameter' do
        it 'return true if options type is nil' do
          expect(@record.validate_parameter({}, '')).to eq(true)
        end

        it 'return true if options type is String and input type is String' do
          options = { 'Default' => 'dummy_default_value', 'Type' => 'String' }

          expect(@record.validate_parameter(options, 'dummy_value')).to eq(true)
        end

        it 'return true if options type is String and input type is CommaDelimitedList' do
          options = { 'Default' => 'dummy_default_value', 'Type' => 'String' }

          expect(@record.validate_parameter(options, 'dummy_value_1, dummy_value_2')).to eq(true)
        end

        it 'return false if options type is String and input type is Fixnum' do
          options = { 'Default' => 'dummy_default_value', 'Type' => 'String' }

          expect(@record.validate_parameter(options, 1)).to eq(false)
        end

        it 'return true if options type is CommaDelimitedList and input type is String' do
          options = { 'Default' => 'dummy_default_value', 'Type' => 'CommaDelimitedList' }

          expect(@record.validate_parameter(options, 'dummy_value')).to eq(true)
        end

        it 'return true if options type is CommaDelimitedList and input type is CommaDelimitedList' do
          options = { 'Default' => 'dummy_default_value', 'Type' => 'CommaDelimitedList' }

          expect(@record.validate_parameter(options, 'dummy_value_1, dummy_value_2')).to eq(true)
        end

        it 'return false if options type is CommaDelimitedList and input type is Fixnum' do
          options = { 'Default' => 'dummy_default_value', 'Type' => 'CommaDelimitedList' }

          expect(@record.validate_parameter(options, 1)).to eq(false)
        end

        it 'return false if options type is Number and input type is String' do
          @options = { 'Default' => 'dummy_default_value', 'Type' => 'Number' }

          expect(@record.validate_parameter(@options, 'dummy_value')).to eq(false)
        end

        it 'return false if options type is Number and input type is CommaDelimitedList' do
          @options = { 'Default' => 'dummy_default_value', 'Type' => 'Number' }

          expect(@record.validate_parameter(@options, 'dummy_value_1, dummy_value_2')).to eq(false)
        end

        it 'return true if options type is Number and input type is Fixnum' do
          @options = { 'Default' => 'dummy_default_value', 'Type' => 'Number' }

          expect(@record.validate_parameter(@options, 1)).to eq(true)
        end
      end

      describe '#clouds_with_priority' do
        before do
          @record.stub(:find_id_by_name).and_return(nil)
          @record.stub(:find_id_by_name).with(:cloud, 'OpenStack').and_return(1)
          @record.stub(:find_id_by_name).with(:cloud, 'AWS').and_return(2)
        end

        it 'return clouds hash that set the priority ' do
          results = @record.clouds_with_priority(%w(OpenStack AWS))

          expect(results.size).to eq(2)
          expect(results.first[:priority]).to be_is_a(Fixnum)
          expect(results.last[:priority]).to be_is_a(Fixnum)
        end

        it 'priority is higher for first' do
          results = @record.clouds_with_priority(%w(OpenStack AWS))

          expect(results.first[:priority] > results.last[:priority]).to eq(true)
        end

        it 'calculate priority by order of argument when clouds table has different order' do
          results = @record.clouds_with_priority(%w(AWS OpenStack))

          expect(results.first[:priority] > results.last[:priority]).to eq(true)

          expect(results[0][:id]).to eq(2)
          expect(results[1][:id]).to eq(1)
        end

        it 'excludes record that does not exist' do
          results = @record.clouds_with_priority(%w(OpenStack DummyCloud AWS))

          expect(results.size).to eq(2)
          expect(results[0][:id]).to eq(1)
          expect(results[1][:id]).to eq(2)
        end
      end

      describe '#stacks' do
        before do
          @record.stub(:input_template_parameters).and_return('dummy_pattern' => { 'dummy_key' => 'dummy_value' })
          @record.stub(:select_by_names).and_return([{ 'id' => 1, 'name' => 'dummy_pattern_name' }])

          dummy_parameter = '{ "dummy_pattern_name": { "dummy_key": "dummy_value" }}'
          File.stub(:read).with('dummy_parameter_file.json').and_return(dummy_parameter)
          dummy_user_attribute = '{ "dummy_pattern_name": { "dummy_attribute": "dummy_attribute_value" } }'
          File.stub(:read).with('dummy_user_attribute_file.json').and_return(dummy_user_attribute)
        end

        it 'return parameters that required to create stack' do
          option = {
            'id' => 1,
            'name' => 'spec_for_record',
            'patterns' => ['dummy_pattern_name'],
            'parameter_file' => 'dummy_parameter_file.json',
            'user_attribute_file' => 'dummy_user_attribute_file.json'
          }

          expected_result = [{
            name: 'spec-for-record-dummy-pattern-name',
            pattern_id: 1,
            template_parameters: '{"dummy_key":"dummy_value"}',
            parameters: '{"dummy_attribute":"dummy_attribute_value"}'
          }]
          expect(@record.stacks option).to eq(expected_result)
        end
      end

      describe '#targets' do
        before do
          @record.stub(:source_image).and_return('ami-12345678')
        end

        it 'call source_image methods ' do
          options = { type: 'aws', entry_point: 'ap-northeast-1' }
          @record.should_receive(:source_image).with(options)

          @record.targets options
        end

        it 'return parameters ' do
          options = { 'type' => 'aws', 'entry_point' => 'ap-northeast-1' }

          expect(@record.targets options).to eq([{ operating_system_id: 1, source_image: 'ami-12345678', ssh_username: 'ec2-user' }])
        end
      end

      describe '#source_image' do
        it 'return base image ID on aws if type is aws' do
          options = {}
          options['type'] = 'aws'
          options['entry_point'] = 'ap-northeast-1'
          expect(@record.source_image(options)).to eq('ami-9b4b789a')

          options['entry_point'] = 'ap-southeast-1'
          expect(@record.source_image(options)).to eq('ami-0eb7965c')

          options['entry_point'] = 'ap-southeast-2'
          expect(@record.source_image(options)).to eq('ami-c50864ff')

          options['entry_point'] = 'eu-west-1'
          expect(@record.source_image(options)).to eq('ami-9210bee5')

          options['entry_point'] = 'eu-central-1'
          expect(@record.source_image(options)).to eq('ami-bc0234a1')

          options['entry_point'] = 'sa-east-1'
          expect(@record.source_image(options)).to eq('ami-ab0fbbb6')

          options['entry_point'] = 'us-east-1'
          expect(@record.source_image(options)).to eq('ami-74da531c')

          options['entry_point'] = 'us-west-1'
          expect(@record.source_image(options)).to eq('ami-5940541c')

          options['entry_point'] = 'us-west-2'
          expect(@record.source_image(options)).to eq('ami-575c1267')
        end

        it 'return base image ID on OpenStack if type is openstack' do
          options = {}
          options['type'] = 'openstack'
          options['base_image_id'] = 'dummy_id'
          expect(@record.source_image(options)).to eq('dummy_id')
        end
      end
    end
  end
end
