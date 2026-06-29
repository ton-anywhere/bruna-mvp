require_relative '../../config/environment'

puts "--- Starting API Test ---"
begin
  if ENV['CEREBRAS_API_KEY'].blank?
    puts "CRITICAL ERROR: CEREBRAS_API_KEY is not set in ENV"
    exit 1
  end

  client = Cerebras::Client.new

  puts "Calling SDK chat completions..."
  # Using a very simple text prompt to isolate the connection and SDK wrapper logic
  response = client.chat.completions.create(
    model: 'gemma-4-31b',
    messages: [
      { role: 'user', content: 'Say hello!' }
    ]
  )

  puts "Response Class: #{response.class}"

  # Test dot notation
  begin
    content = response.choices.first.message.content
    puts "SUCCESS: Received content: #{content}"
  rescue => e
    puts "FAILURE: Could not traverse response: #{e.message}"
    puts "Response Data: #{response.inspect}"
  end

rescue StandardError => e
  puts "CRITICAL ERROR: #{e.class} - #{e.message}"
  puts e.backtrace.first(5).join("\n")
end
