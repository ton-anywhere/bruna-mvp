class VisionAnalysisService
  def self.call(base64_image)
    if ENV['CEREBRAS_API_KEY'].blank?
      return { reasoning: '', answer: 'Error: CEREBRAS_API_KEY is not set' }
    end

    # Preserve the original Data URI prefix if present, as it contains the correct MIME type (png, jpeg, etc.)
    # If no prefix is present, default to image/png.
    image_url = if base64_image.start_with?('data:image/')
                  base64_image
                else
                  "data:image/png;base64,#{base64_image}"
                end

    client = Cerebras::Client.new

    Rails.logger.debug '[VisionAnalysisService] Calling SDK chat completions create...'
    Rails.logger.debug "[VisionAnalysisService] REQUEST-INIT: Image length: #{image_url.length}"
    response = client.chat.completions.create(

      model: 'gemma-4-31b',
      messages: [
        {
          role: 'user',
          content: [
            { 
              type: 'text', 
              text: <<~PROMPT
                Act as a ruthless but constructive senior design lead. Your goal is to provide a professional UI audit of the provided screenshot. 

                Do not provide generic praise (e.g., do not say "the design is clean" or "looks good"). Instead, provide a standards-based critique focusing on efficiency, accessibility, and professional polish.

                The output must be a critique, not a description. Structure your response using the following Markdown headers:

                ### Accessibility
                Focus on WCAG compliance, color contrast, legible typography, and touch targets.

                ### Visual Hierarchy
                Focus on alignment, focal points, spacing, and the use of typography to guide the eye.

                ### UX Friction
                Focus on cognitive load, confusing interaction patterns, and potential user pain points.
              PROMPT
            },
            { type: 'image_url', image_url: { url: image_url } }
          ]
        }
      ],
       max_tokens: 1000
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
