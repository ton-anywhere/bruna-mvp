require 'base64'
require 'json'
require 'net/http'
require 'uri'
require 'dotenv/load'

# 1. Load image to base64
image_path = './spec/smoke/test_image.jpg'
unless File.exist?(image_path)
  puts "Error: Image not found at #{image_path}"
  exit 1
end

image_data = File.read(image_path)
base64_image = Base64.strict_encode64(image_data)
data_uri = "data:image/jpeg;base64,#{base64_image}"

# 2. API Config
api_key = ENV['CEREBRAS_API_KEY']
if api_key.nil? || api_key.empty?
  puts "Error: CEREBRAS_API_KEY not found in environment"
  exit 1
end

url = URI("https://api.cerebras.ai/v1/chat/completions")
http = Net::HTTP.new(url.host, url.port)
http.use_ssl = true

# 3. Construct Payload
payload = {
  model: "gemma-4-31b", # Adjust model if necessary based on current specs
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

request = Net::HTTP::Post.new(url)
request["Authorization"] = "Bearer #{api_key}"
request["Content-Type"] = "application/json"
request.body = payload.to_json

# 4. Execute and Print
puts "Sending request to Cerebras API..."
response = http.request(request)
puts "Response Code: #{response.code}"
puts "Response Body:\n#{response.body}"
