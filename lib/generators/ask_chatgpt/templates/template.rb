AskChatGPT.setup do |config|
  # config.access_token    = ENV["OPENAI_API_KEY"]

  # async mode will use OpenAI streamming feature and will return results as they come
  # config.mode             = :async # or :sync
  # config.markdown         = true # try to convert response if Markdown
  # config.debug            = false
  # config.model            = "gpt-3.5-turbo"
  # config.max_tokens       = 3000 # or nil by default
  # config.temperature      = 0.1
  # config.included_prompts = []

  # Examples of custom prompts:
  # you can use them `gpt.ask(:extract_email, "some string")`

  # config.register_prompt :extract_email do |arg|
  #   "Extract email from: #{arg} as JSON"
  # end

  # config.register_prompt :extract_constants do |arg|
  #   "Extract constants from class: #{AskChatGPT::Helpers.extract_source(arg)}"
  # end

  # config.register_prompt :i18n do |code|
  #   "Use I18n in this code:\n#{AskChatGPT::Helpers.extract_source(code)}"
  # end
end
