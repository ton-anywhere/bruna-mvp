require 'rails_helper'

RSpec.describe VisionAnalysisService do
  let(:base64_image) { 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8/5+hHgAHggK7P6S5XwAAAABJRU5ErkJggg==' }
  let(:experts_config) { YAML.load_file(Rails.root.join('config', 'expert_panel.yml'))['experts'] }

  describe '.call' do
    it 'triggers parallel calls for each expert and broadcasts results individually' do
      allow(Cerebras::Client).to receive(:new).and_return(client_double)
      allow(client_double).to receive(:chat).and_return(chat_double)
      allow(chat_double).to receive(:completions).and_return(completions_double)

      expect(completions_double).to receive(:create).exactly(experts_config.keys.size).times.and_return(mock_response)

      # We expect 4 distinct broadcasts. Use a simple counter or check for each agent_id.
      expect(ActionCable.server).to receive(:broadcast).exactly(experts_config.keys.size).times.with(
        'vision_channel',
        hash_including(content: 'Final Answer', status: 'success')
      )

      VisionAnalysisService.call(base64_image)
    end

    it 'scrubs reasoning tokens from the broadcast content' do
      allow(Cerebras::Client).to receive(:new).and_return(client_double)
      allow(client_double).to receive_message_chain(:chat, :completions, :create).and_return(
        mock_response_with_reasoning
      )

      # Verify that the content sent to broadcast does NOT contain the reasoning string
      expect(ActionCable.server).to receive(:broadcast).exactly(experts_config.keys.size).times do |channel, payload|
        expect(channel).to eq('vision_channel')
        expect(payload[:content]).to eq('Final Answer')
        expect(payload).not_to have_key(:reasoning)
      end

      VisionAnalysisService.call(base64_image)
    end

    it 'broadcasts an error for an agent if its call fails, without stopping others' do
      allow(Cerebras::Client).to receive(:new).and_return(client_double)
      allow(client_double).to receive(:chat).and_return(chat_double)
      allow(chat_double).to receive(:completions).and_return(completions_double)

      # Simulate one failure and others succeeding
      call_count = 0
      allow(completions_double).to receive(:create) do
        call_count += 1
        raise StandardError, 'SDK Timeout' if call_count == 1
        mock_response
      end

      # Expect exactly one error broadcast
      expect(ActionCable.server).to receive(:broadcast).with(
        'vision_channel',
        hash_including(status: 'error', content: /Error analyzing/)
      ).once

      # The other 3 should still succeed
      expect(ActionCable.server).to receive(:broadcast).with(
        'vision_channel',
        hash_including(status: 'success')
      ).exactly(experts_config.keys.size - 1).times

      VisionAnalysisService.call(base64_image)
    end
  end

  # Helpers for mocks
  let(:client_double) { instance_double('Cerebras::Client') }
  let(:chat_double) { double('chat') }
  let(:completions_double) { double('completions') }

  let(:mock_response) do
    double('Response', choices: [
      double('Choice', message: double('Message', content: 'Final Answer', reasoning: 'Some reasoning'))
    ])
  end

  let(:mock_response_with_reasoning) do
    double('Response', choices: [
      double('Choice', message: double('Message', content: 'Final Answer', reasoning: 'This is a secret reasoning'))
    ])
  end
end

# Helper matcher for hash contents
RSpec::Matchers.define :hash_including do |expected|
  match do |actual|
    expected.all? { |k, v| actual[k] == v || (v.is_a?(Regexp) && actual[k] =~ v) }
  end
end
