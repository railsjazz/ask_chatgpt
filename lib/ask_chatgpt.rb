require "ask_chatgpt/version"
require "ask_chatgpt/railtie"
require "net/http"
require "json"
require "openai"
require "tty-markdown"
require "tty-spinner"

require_relative "ask_chatgpt/executor"
require_relative "ask_chatgpt/core"

module AskChatgpt
  mattr_accessor :debug
  @@debug = false

  # https://platform.openai.com/docs/models
  mattr_accessor :model
  @@model = "gpt-3.5-turbo"

  # https://platform.openai.com/docs/api-reference/completions/create#completions/create-temperature
  mattr_accessor :temperature
  @@temperature = 0.2

  mattr_accessor :access_token
  @@access_token = ENV["OPENAI_API_KEY"]

  module ConsoleMethods
    def gpt
      AskChatGPT::Core.call
    end

    alias :chatgpt :gpt
    alias :chat_gpt :gpt

    def run(*args)
      gpt(*args)
    end
  end

  extend ConsoleMethods
end

AskChatGPT = AskChatgpt
