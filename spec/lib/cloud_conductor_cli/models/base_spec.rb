module CloudConductorCli
  module Models
    describe Base do
      describe '.included' do
        it 'define class_options when included' do
          new_model = Class.new(Thor)
          expect(new_model).to receive(:class_option).with(:host, hash_including(aliases: '-H'))
          expect(new_model).to receive(:class_option).with(:port, hash_including(aliases: '-p'))
          new_model.send(:include, Models::Base)
        end
      end
    end
  end
end
