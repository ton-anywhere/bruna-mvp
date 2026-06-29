class VisionChannel < ApplicationCable::Channel
  def subscribed
    stream_from 'vision_channel'
  end

  def receive(data)
    Rails.logger.warn '!!! VISION CHANNEL: RECEIVED PAYLOAD START !!!'
    Rails.logger.info "VisionChannel: Received payload keys: #{data.keys.inspect}"

    return unless data['image'].present?

    # Send immediate acknowledgement to client
    transmit({ status: 'acknowledged', message: 'Image received, analyzing...' })

    # The service now handles asynchronous broadcasting of results for each agent individually.
    # We simply trigger the service; the responses will flow back via the 'vision_channel' stream.
    VisionAnalysisService.call(data['image'])

    Rails.logger.warn '!!! VISION CHANNEL: RECEIVED PAYLOAD HANDLED !!!'
  rescue StandardError => e
    Rails.logger.error "Unable to process VisionChannel#receive: #{e.message}"
    transmit({
      status: 'error',
      content: "Critical Error: #{e.message}"
    })
  end
end
