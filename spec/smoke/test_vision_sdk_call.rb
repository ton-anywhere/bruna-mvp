require_relative '../../config/environment'

# 1. Load image to base64
image_path = './spec/smoke/test_image.jpg'
unless File.exist?(image_path)
  puts "Error: Image not found at #{image_path}"
  exit 1
end

image_data = File.read(image_path)
base64_image = Base64.strict_encode64(image_data)
data_uri = "data:image/jpeg;base64,#{base64_image}"

# 2. SDK Client Initialization
# The SDK automatically picks up CEREBRAS_API_KEY from ENV
begin
  client = Cerebras::Client.new
rescue StandardError => e
  puts "Error initializing Cerebras Client: #{e.message}"
  exit 1
end

# 3. Construct Payload using SDK patterns
params = {
  model: "gemma-4-31b",
  messages: [
    {
      role: "user",
      content: [
        { type: "text", text: "What is in this image? Please describe it in detail." },
        { type: "image_url", image_url: { url: data_uri } }
      ]
    }
  ],
  max_tokens: 500
}

# 4. Execute and Print
puts "Sending request to Cerebras API via SDK..."
begin
  response = client.chat.completions.create(params)

  puts "Response received successfully!"
  # Response is a ResponseWrapper, use method access or to_h
  content = response.choices[0].message.content
  puts "Content: #{content}"
  puts "\nFull Response Body:\n#{response.inspect}"
rescue StandardError => e
  puts "API Request failed: #{e.class} - #{e.message}"
  exit 1
end
