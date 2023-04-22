module AskChatgpt
  class Core
    def self.call
      client = OpenAI::Client.new(access_token: AskChatGPT.access_token)
      AskChatgpt::Executor.new(client)
    end
  end
end
