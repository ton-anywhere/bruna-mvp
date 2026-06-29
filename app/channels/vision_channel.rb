class VisionChannel < ApplicationCable::Channel
  def subscribed
    stream_from 'vision_channel'
  end

  def receive(data)
    Rails.logger.info "VisionChannel: Received frame of size #{data['image']&.length} bytes"

    return unless data['image'].present?

    begin
      result = VisionAnalysisService.call(data['image'])

      transmit({
        reasoning: result[:reasoning],
        answer: result[:answer]
      })
    rescue StandardError => e
      Rails.logger.error "Unable to process VisionChannel#received: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")

      transmit({
        reasoning: '',
        answer: "Critical Error: #{e.message}"
      })
    end
  end
end
