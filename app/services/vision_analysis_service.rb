class VisionAnalysisService
  def self.call(base64_image)
    if ENV['CEREBRAS_API_KEY'].blank?
      return { reasoning: '', answer: 'Error: CEREBRAS_API_KEY is not set' }
    end

    # Ensure we have a clean base64 string by removing any existing data URI prefix
    # This prevents double-prefixing or malformed prefixes from the frontend
    raw_base64 = base64_image.sub(/^data:image\/[a-z]+;base64,/, '')
    image_url = "data:image/jpeg;base64,#{raw_base64}"

    client = Cerebras::Client.new

    Rails.logger.debug '[VisionAnalysisService] Calling SDK chat completions create...'
    Rails.logger.debug "[VisionAnalysisService] REQUEST-INIT: Image length: #{image_url.length}"
    response = client.chat.completions.create(

      model: 'gemma-4-31b',
      messages: [
        {
          role: 'user',
          content: [
            { type: 'text', text: 'What is in this image? Please describe it concisely.' },
            { type: 'image_url', image_url: { url: image_url } }
          ]
        }
      ],
      max_tokens: 500
    )
    Rails.logger.debug "[VisionAnalysisService] FULL-RESPONSE-DUMP: #{response.inspect}"

    Rails.logger.debug "[VisionAnalysisService] Response Class: #{response.class}"

    begin
      choices = response.respond_to?(:choices) ? response.choices : []
      Rails.logger.debug "[VisionAnalysisService] TRAVERSAL-DATA: Choices count: #{choices.length}"
      first_choice = choices.first


      if first_choice.respond_to?(:message)
        message = first_choice.message
        Rails.logger.debug "[VisionAnalysisService] MESSAGE-METHODS: #{message.respond_to?(:methods) ? message.methods.sort.join(', ') : 'N/A'}"
        res_reasoning = message.respond_to?(:reasoning) ? message.reasoning : (message.is_a?(Hash) ? message[:reasoning] : '')

        res_content = message.respond_to?(:content) ? message.content : (message.is_a?(Hash) ? message[:content] : '')

        Rails.logger.debug "[VisionAnalysisService] FINAL-EXTRACTION: reasoning: #{res_reasoning.to_s[0..100]}..., content: #{res_content.to_s[0..100]}..."
        {
          reasoning: res_reasoning || '',
          answer: res_content || ''
        }

      else
        { reasoning: '', answer: '' }
      end
    rescue StandardError => e
      Rails.logger.error "[VisionAnalysisService] PARSING-EXCEPTION-DETAIL: #{e.class}: #{e.message}\n#{e.backtrace.join("\n")}"
      {
        reasoning: '',
        answer: "Error parsing response: #{e.message}"
      }

    end
  rescue StandardError => e
    Rails.logger.error "[VisionAnalysisService] SDK-EXCEPTION-DETAIL: #{e.class}: #{e.message}\n#{e.backtrace.join("\n")}"
    {
      reasoning: '',
      answer: "Error: #{e.message}"
    }
  end
end
