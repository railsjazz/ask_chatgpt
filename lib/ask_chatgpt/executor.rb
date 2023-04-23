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
      @scope = AskChatGPT.included_prompt.dup
      @client = client
    end

    def with_model(*models)
      models.each do |model|
        @scope << AskChatGPT::Prompts::Model.new(model)
      end
      self
    end

    alias :with_models :with_model

    [:improve, :refactor, :question, :find_bug, :code_review, :rspec_test, :unit_test, :explain].each do |method|
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
      pp parameters if AskChatGPT.debug
      puts(call); nil
    end

    def call
      if scope.empty? || (scope.size == 1 && scope.first.is_a?(AskChatGPT::Prompts::App))
        return puts("No prompts given")
      end

      spinner = TTY::Spinner.new(format: :classic)
      spinner.auto_spin
      response = client.chat(parameters: parameters)
      spinner.stop

      pp response if AskChatGPT.debug

      if response["error"]
        puts response["error"]["message"]
      else
        content = response.dig("choices", 0, "message", "content")
        parsed = TTY::Markdown.parse(content)
        parsed
      end
    ensure
      spinner.stop if spinner.spinning?
    end

    def parameters
      @parameters ||= {
        model: AskChatGPT.model,
        temperature: AskChatGPT.temperature,
        max_tokens: AskChatGPT.max_tokens,
        messages: scope.map { |e| { role: "user", content: e.content } },
      }.compact_blank
    end
  end
end
