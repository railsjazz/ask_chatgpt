AskChatGPT.setup do |config|
  # config.access_token = ENV["OPENAI_API_KEY"]
  config.debug = false
  # config.model = "gpt-3.5-turbo"
  # config.temperature = 0.1
  config.max_tokens = 3000
  config.included_prompts = [AskChatGPT::Prompts::App.new]
  # config.included_prompts = []

  config.voice_enabled = true
  config.audio_device_id = 1
  config.voice_max_duration = 10 # 10 seconds

  config.register_prompt :extract_email do |arg|
    "Extract email from: #{arg} as JSON"
  end

  config.register_prompt :extract_constants do |arg|
    "Extract constants from class: #{AskChatGPT::Helpers.extract_source(arg)}"
  end

  config.register_prompt :i18n do |code|
    "Use I18n in this code:\n#{AskChatGPT::Helpers.extract_source(code)}"
  end
end
