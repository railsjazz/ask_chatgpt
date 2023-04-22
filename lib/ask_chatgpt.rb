require "ask_chatgpt/version"
require "ask_chatgpt/railtie"
require "net/http"
require "json"
require "openai"
require "tty-markdown"

require_relative "ask_chatgpt/prompts/base"
require_relative "ask_chatgpt/prompts/app"
require_relative "ask_chatgpt/prompts/model"
require_relative "ask_chatgpt/prompts/question"

module AskChatgpt
  mattr_accessor :debug
  @@debug = false

  mattr_accessor :model
  @@model = "gpt-3.5-turbo"

  mattr_accessor :temperature
  @@temperature = 0.8

  module ConsoleMethods
    def gpt
      ChatGPT.call
    end

    def run(*args)
      gpt(*args)
    end
  end
  extend ConsoleMethods

  class PromptBuilder
    attr_reader :scope, :client

    def initialize(client)
      @scope = [AskChatGPT::Prompts::App.new]
      @client = client
    end

    def with_model(*models)
      models.each do |model|
        @scope << AskChatGPT::Prompts::Model.new(model)
      end
      self
    end

    def ask(question)
      @scope << AskChatGPT::Prompts::Question.new(question)
      self
    end

    def inspect
      puts(call); nil
    end

    def call
      pp parameters if AskChatGPT.debug

      response = client.chat(parameters: parameters)
      content = response.dig("choices", 0, "message", "content")
      parsed = TTY::Markdown.parse(content)
      parsed
    end

    def parameters
      {
        model: AskChatGPT.model,
        messages: scope.map { |e| { role: "user", content: e.content } },
        temperature: AskChatGPT.temperature,
      }
    end
  end

  class ChatGPT
    def self.call
      client = OpenAI::Client.new(access_token: ENV["OPENAI_API_KEY"])
      PromptBuilder.new(client)
    end
  end
end

AskChatGPT = AskChatgpt
