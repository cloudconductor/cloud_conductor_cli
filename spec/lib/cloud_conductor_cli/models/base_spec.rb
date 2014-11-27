module CloudConductorCli
  module Models
    describe Base do

      describe '.included' do
        it 'call class_option when include Base module' do
          class Dummy < Thor
          end
          Dummy.should_receive(:class_option).with(:host, aliases: '-H', type: :string,
                                                          desc: 'CloudConductor server host. use CC_HOST environment if not specified.')
          Dummy.should_receive(:class_option).with(:port, aliases: '-p', type: :string,
                                                          desc: 'CloudConductor server port. use CC_PORT environment if not specified.')

          Base.included(Dummy)
        end
      end
    end
  end
end
