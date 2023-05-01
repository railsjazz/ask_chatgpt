module AskChatgpt
  module Console
    def gpt
      AskChatGPT::Executor.call
    end

    alias :chatgpt :gpt
    alias :chat_gpt :gpt

    def run(*args)
      gpt(*args)
    end
  end
end
