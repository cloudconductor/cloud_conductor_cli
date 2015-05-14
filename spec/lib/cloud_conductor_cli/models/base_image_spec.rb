require 'active_support/core_ext'

module CloudConductorCli
  module Models
    describe BaseImage do
      let(:base_image) { CloudConductorCli::Models::BaseImage.new }
      let(:commands) { CloudConductorCli::Models::BaseImage.commands }
      let(:mock_base_image) do
        {
          id: 1,
          cloud_id: 1,
          os: 'CentOS-6.5',
          source_image: 'uuid',
          ssh_username: 'ec2-user'
        }
      end

      before do
        allow(CloudConductorCli::Helpers::Connection).to receive(:new).and_return(double(get: true, post: true, put: true, delete: true, request: true))
        allow(base_image).to receive(:find_id_by).with(:base_image, :source_image, anything).and_return(mock_base_image[:id])
        allow(base_image).to receive(:find_id_by).with(:cloud, :name, anything).and_return(1)
        allow(base_image).to receive(:output)
        allow(base_image).to receive(:message)
      end

      describe '#list' do
        let(:mock_response) { double(status: 200, headers: [], body: JSON.dump([mock_base_image])) }
        before do
          allow(base_image.connection).to receive(:get).with('/base_images').and_return(mock_response)
        end

        it 'allow valid options' do
          allowed_options = []
          expect(commands['list'].options.keys).to match_array(allowed_options)
        end

        it 'request GET /base_images' do
          expect(base_image.connection).to receive(:get).with('/base_images')
          base_image.list
        end

        it 'display record list' do
          expect(base_image).to receive(:output).with(mock_response)
          base_image.list
        end
      end

      describe '#show' do
        let(:mock_response) { double(status: 200, headers: [], body: JSON.dump(mock_base_image)) }
        before do
          allow(base_image.connection).to receive(:get).with("/base_images/#{mock_base_image[:id]}").and_return(mock_response)
        end

        it 'allow valid options' do
          allowed_options = []
          expect(commands['show'].options.keys).to match_array(allowed_options)
        end

        it 'request GET /base_images/:id' do
          expect(base_image.connection).to receive(:get).with("/base_images/#{mock_base_image[:id]}")
          base_image.show('source_image_id')
        end

        it 'display record details' do
          expect(base_image).to receive(:output).with(mock_response)
          base_image.show('source_image_id')
        end
      end

      describe '#create' do
        let(:mock_response) { double(status: 201, headers: [], body: JSON.dump(mock_base_image)) }
        before do
          allow(base_image.connection).to receive(:post).with('/base_images', anything).and_return(mock_response)
        end

        it 'allow valid options' do
          allowed_options = [:cloud, :source_image, :ssh_username]
          expect(commands['create'].options.keys).to match_array(allowed_options)
        end

        it 'request POST /base_images with payload' do
          base_image.options = mock_base_image.stringify_keys.except('id', 'cloud_id').merge('cloud' => 'cloud_name')
          payload = base_image.options.except('cloud').merge('cloud_id' => 1)
          expect(base_image.connection).to receive(:post).with('/base_images', payload)
          base_image.create
        end

        it 'display message and record details' do
          expect(base_image).to receive(:message)
          expect(base_image).to receive(:output).with(mock_response)
          base_image.create
        end
      end

      describe '#update' do
        let(:mock_response) { double(status: 200, headers: [], body: JSON.dump(mock_base_image)) }
        before do
          allow(base_image.connection).to receive(:put).with("/base_images/#{mock_base_image[:id]}", anything).and_return(mock_response)
        end

        it 'allow valid options' do
          allowed_options = [:source_image, :ssh_username]
          expect(commands['update'].options.keys).to match_array(allowed_options)
        end

        it 'request PUT /base_images/:id with payload' do
          base_image.options = mock_base_image.except(:id, :cloud_id, :os)
          payload = base_image.options
          expect(base_image.connection).to receive(:put).with("/base_images/#{mock_base_image[:id]}", payload)
          base_image.update('source_image_id')
        end

        it 'display message and record details' do
          expect(base_image).to receive(:message)
          expect(base_image).to receive(:output).with(mock_response)
          base_image.update('source_image_id')
        end
      end

      describe '#delete' do
        let(:mock_response) { double(status: 204, headers: [], body: JSON.dump('')) }
        before do
          allow(base_image.connection).to receive(:delete).with("/base_images/#{mock_base_image[:id]}").and_return(mock_response)
        end

        it 'allow valid options' do
          allowed_options = []
          expect(commands['delete'].options.keys).to match_array(allowed_options)
        end

        it 'request DELETE /base_images/:id' do
          expect(base_image.connection).to receive(:delete).with("/base_images/#{mock_base_image[:id]}")
          base_image.delete('source_image_id')
        end

        it 'display message' do
          expect(base_image).to receive(:message)
          base_image.delete('source_image_id')
        end
      end
    end
  end
end
