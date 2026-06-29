class VisionAnalysisService
  def self.call(base64_image)
    if ENV['CEREBRAS_API_KEY'].blank?
      # Since we are now broadcasting, we handle the missing key by broadcasting a general error
      # or handling it within the parallel loop. For consistency with the new flow:
      broadcast_error('system', 'Error: CEREBRAS_API_KEY is not set')
      return
    end

    experts_config = YAML.load_file(Rails.root.join('config', 'expert_panel.yml'))['experts'] || {}

    image_url = if base64_image.start_with?('data:image/')
                  base64_image
    else
                  "data:image/png;base64,#{base64_image}"
    end

    threads = experts_config.map do |agent_id, config|
      Thread.new do
        begin
          client = Cerebras::Client.new

          # We use streaming to provide a better UX
          client.chat.completions.create(
            model: 'gemma-4-31b',
            messages: [
              {
                role: 'user',
                content: [
                  { type: 'text', text: config['system_prompt'] },
                  { type: 'image_url', image_url: { url: image_url } }
                ]
              }
            ],
            max_tokens: 600,
            stream: true
          ) do |chunk|
            # The SDK yields a ResponseWrapper. We need to extract the content delta.
            # Based on standard LLM stream responses, the content is in choices[0].delta.content
            delta_content = extract_delta(chunk)

            if delta_content.present?
              ActionCable.server.broadcast('vision_channel', {
                agent_id: agent_id,
                content: delta_content,
                status: 'streaming'
              })
            end
          end

          # Signal that this agent has finished
          ActionCable.server.broadcast('vision_channel', {
            agent_id: agent_id,
            status: 'success'
          })
        rescue StandardError => e
          Rails.logger.error "[VisionAnalysisService] Agent #{agent_id} failed: #{e.message}"
          broadcast_error(agent_id, 'Error analyzing. Please try again.')
        end
      end
    end

    threads.each(&:join)
  end

  private

  def self.extract_delta(chunk)
    # The chunk is a Cerebras::ResponseWrapper.
    # It uses method_missing to allow access like chunk.choices.first.delta.content
    begin
      choices = chunk.choices
      return '' unless choices && choices.any?

      first_choice = choices.first
      delta = first_choice.delta
      delta.content || ''
    rescue StandardError => e
      Rails.logger.debug "[VisionAnalysisService] extract_delta parsing: #{e.message}"
      ''
    end
  end

  def self.extract_content(response)
    choices = response.respond_to?(:choices) ? response.choices : []
    first_choice = choices.first
    return '' unless first_choice&.respond_to?(:message)

    message = first_choice.message
    message.respond_to?(:content) ? message.content : (message.is_a?(Hash) ? message[:content] : '')
  end

  def self.broadcast_error(agent_id, message)
    ActionCable.server.broadcast('vision_channel', {
      agent_id: agent_id,
      content: message,
      status: 'error'
    })
  end
end
