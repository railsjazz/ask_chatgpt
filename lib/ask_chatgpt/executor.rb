require_relative "prompts/base"
require_relative "prompts/improve"
Dir[File.join(__dir__, "prompts", "*.rb")].each do |file|
  require file
end

# for inspiration:
# https://www.greataiprompts.com/chat-gpt/best-coding-prompts-for-chat-gpt/

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

    alias :with_models :with_model

    [:improve, :refactor, :question, :find_bug, :code_review, :rspec_test, :unit_test].each do |method|
      define_method(method) do |*args|
        @scope << AskChatGPT::Prompts.const_get(method.to_s.camelize).new(*args)
        self
      end
    end

    alias :ask :question
    alias :how :question
    alias :find :question
    alias :review :code_review

    def inspect
      puts(call); nil
    end

    def call
      pp parameters if AskChatGPT.debug

      return puts("No prompts given") if scope.size == 1 # only App prompt

      spinner = TTY::Spinner.new(format: :classic)
      spinner.auto_spin

      response = client.chat(parameters: parameters)
      content = response.dig("choices", 0, "message", "content")
      spinner.stop

      parsed = TTY::Markdown.parse(content)
      parsed
    ensure
      spinner.stop if spinner.spinning?
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
