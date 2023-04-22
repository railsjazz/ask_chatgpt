require_relative "prompts/base"
Dir[File.join(__dir__, "prompts", "*.rb")].each do |file|
  require file
end

module AskChatgpt
  class Executor
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

    def improve(method)
      @scope << AskChatGPT::Prompts::Improve.new(method)
      self
    end

    def refactor(method)
      @scope << AskChatGPT::Prompts::Refactor.new(method)
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

      spinner = TTY::Spinner.new(format: :classic)
      spinner.auto_spin

      response = client.chat(parameters: parameters)
      content = response.dig("choices", 0, "message", "content")
      spinner.stop

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
end
