require 'rails_helper'

RSpec.describe VisionChannel, type: :controller do
  let(:connection) { instance_double('ActionCable::Connection::Base', identifiers: {}, logger: double('logger')) }
  let(:params) { {} }
  let(:channel) { VisionChannel.new(connection, params) }

  describe '#receive' do
    it 'transmits the analysis result' do
      expect(channel).to receive(:transmit).with(hash_including(:reasoning, :answer))
      channel.receive({ 'image' => 'a' * 123 })
    end

    it 'handles missing image data gracefully' do
      expect(channel).not_to receive(:transmit)
      channel.receive({ 'image' => nil })
    end
  end
end
