# todo: Using the gem openai-ruby but should use official one or just implement our own client
class OpenaiClient
  def initialize(api_key: Rails.application.credentials.dig(:openai_api, :api_key))
    @client = OpenAI::Client.new(api_key: api_key)
  end

  def call(messages:, model:"gpt-4o-mini", temperature: 0.2, response_format: { type: "json_object" })
    response = @client.chat.completions.create(
      model: model,
      messages: messages,
      temperature: temperature,
      response_format: response_format
    )

    extract_text_from_chat(response, json: true)
  rescue => e
    Rails.logger.info("OpenAI API failed: #{e.class} - #{e.message}")
    nil
  end

  private

  def extract_text_from_chat(response, json: false)
    if json
      JSON.parse(response.choices[0].message.content)
    else
      response.choices[0].message.content
    end
  end
end

# exemple usage
# client = OpenaiClient.new
# response = client.call(messages: [{ role: "user", content: "Hello, how are you?" }])
# puts response