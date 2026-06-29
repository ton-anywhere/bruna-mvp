require 'rails_helper'

RSpec.describe VisionAnalysisService do
  let(:base64_image) { 'data:image/jpeg;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==' }

  describe '.call' do
    let(:raw_base64) { 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==' }
    let(:base64_with_prefix) { "data:image/jpeg;base64,#{raw_base64}" }

    context 'when the SDK call is successful' do
      let(:mock_message) do
        double('Message',
          reasoning: 'The image shows a small red dot.',
          content: 'A small red dot.'
        )
      end

      let(:mock_choice) do
        double('Choice', message: mock_message)
      end

      # Simulate ResponseWrapper using object-style access
      let(:mock_response_wrapper) do
        double('ResponseWrapper', choices: [ mock_choice ])
      end

      let(:completions_double) { double('Completions', create: mock_response_wrapper) }
      let(:chat_double) { double('Chat', completions: completions_double) }
      let(:client_double) { double('Client', chat: chat_double) }

      before do
        allow(Cerebras::Client).to receive(:new).and_return(client_double)
      end

      it 'returns the correct reasoning when SDK returns ResponseWrapper' do
        result = VisionAnalysisService.call(base64_with_prefix)
        expect(result[:reasoning]).to eq('The image shows a small red dot.')
      end

      it 'returns the correct answer when SDK returns ResponseWrapper' do
        result = VisionAnalysisService.call(base64_with_prefix)
        expect(result[:answer]).to eq('A small red dot.')
      end

      it 'correctly handles raw base64 input by adding prefix' do
        # Verify the SDK receives the prefixed version
        expect(completions_double).to receive(:create).with(
          hash_including(
            messages: [
              hash_including(
                content: [
                  { type: 'text', text: anything },
                  { type: 'image_url', image_url: { url: base64_with_prefix } }
                ]
              )
            ]
          )
        ).and_return(mock_response_wrapper)

        VisionAnalysisService.call(raw_base64)
      end

      it 'does not double-prefix already prefixed images' do
        expect(completions_double).to receive(:create).with(
          hash_including(
            messages: [
              hash_including(
                content: [
                  { type: 'text', text: anything },
                  { type: 'image_url', image_url: { url: base64_with_prefix } }
                ]
              )
            ]
          )
        ).and_return(mock_response_wrapper)

        VisionAnalysisService.call(base64_with_prefix)
      end

      it 'handles empty choices gracefully' do
        empty_response = double('ResponseWrapper', choices: [])
        allow(completions_double).to receive(:create).and_return(empty_response)

        result = VisionAnalysisService.call(base64_with_prefix)
        expect(result).to eq({ reasoning: '', answer: '' })
      end
    end

    context 'when the SDK call fails' do
      context 'when the API key is missing' do
        before do
          allow(ENV).to receive(:[]).with('CEREBRAS_API_KEY').and_return(nil)
          allow(Cerebras::Client).to receive(:new).and_raise(StandardError.new('API Key Error'))
        end

        let(:result) { VisionAnalysisService.call(base64_image) }

        it 'returns an empty reasoning string on failure' do
          expect(result[:reasoning]).to eq('')
        end

        it 'prefixes the answer with "Error:" on failure' do
          expect(result[:answer]).to start_with('Error:')
        end

        it 'includes the correct error message in the answer' do
          expect(result[:answer]).to eq('Error: CEREBRAS_API_KEY is not set')
        end
      end

      before do
        allow(Cerebras::Client).to receive(:new).and_raise(StandardError.new('API Key Error'))
      end
    end
  end
end
