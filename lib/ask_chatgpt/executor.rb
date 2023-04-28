require_relative "prompts/base"
require_relative "prompts/improve"
Dir[File.join(__dir__, "prompts", "*.rb")].each do |file|
  require file
end

# for inspiration:
# https://www.greataiprompts.com/chat-gpt/best-coding-prompts-for-chat-gpt/

module AskChatgpt
  class InputError < StandardError; end

  class Executor
    DEFAULT_PROMPTS = [:improve, :refactor, :question, :find_bug, :code_review, :rspec_test, :unit_test, :explain]

    attr_reader :scope, :client, :spinner, :cursor

    def initialize(client)
      @scope   = AskChatGPT.included_prompt.dup
      @client  = client
      @spinner = TTY::Spinner.new(format: :classic)
      @cursor  = TTY::Cursor
    end

    def debug!(mode = :on)
      AskChatGPT.debug = mode == :on
    end

    def sync!
      AskChatGPT.mode = :sync
    end

    def async!
      AskChatGPT.mode = :async
    end

    def with_model(*models)
      self.tap do
        models.each do |model|
          add_prompt AskChatGPT::Prompts::Model.new(model)
        end
      end
    end
    alias :with_models :with_model

    DEFAULT_PROMPTS.each do |method|
      define_method(method) do |*args|
        add_prompt(AskChatGPT::Prompts.const_get(method.to_s.camelize).new(*args))
      end
    end
    alias :ask :question
    alias :payload :question
    alias :how :question
    alias :find :question
    alias :review :code_review

    def inspect
      pp(executor_parameters) if AskChatGPT.debug
      call_with_validations do
        case AskChatGPT.mode
        when :async
          call_async
        else
          call_sync
        end
      end
    rescue InputError => e
      puts e.message
    rescue StandardError => e
      puts e.message
      puts e.backtrace.take(5).join("\n")
    ensure
      nil
    end

    def call_with_validations
      if scope.empty? || (scope.size == 1 && scope.first.is_a?(AskChatGPT::Prompts::App))
        raise InputError, "No prompts given"
      end
      yield
    end

    def call_async
      # we will collect all chunks and print them at once later with Markdown
      content = []
      print cursor.save

      spinner.auto_spin
      response = client.chat(parameters: executor_parameters.merge({
        stream: proc do |chunk, _bytesize|
          spinner.stop if spinner&.spinning?
          content_part = chunk.dig("choices", 0, "delta", "content")
          content << content_part
          print content_part
        end
      }))

      spinner&.stop

      print cursor.restore
      print cursor.down
      print cursor.clear_screen_down
      parsed = TTY::Markdown.parse(content.compact.join)
      puts parsed
    ensure
      spinner.stop if spinner&.spinning?
    end

    def call_sync
      spinner.auto_spin
      response = client.chat(parameters: executor_parameters)
      pp(response) if AskChatGPT.debug
      spinner&.stop

      if response["error"]
        puts(response["error"]["message"])
      else
        content = response.dig("choices", 0, "message", "content")
        parsed = TTY::Markdown.parse(content)
        puts(parsed)
      end
    ensure
      spinner.stop if spinner&.spinning?
    end

    def executor_parameters
      @executor_parameters ||= {
        model: AskChatGPT.model,
        temperature: AskChatGPT.temperature,
        max_tokens: AskChatGPT.max_tokens,
        messages: scope.map { |e| { role: "user", content: e.content } }.reject { |e| e[:content].blank? },
      }.compact_blank
    end

    def add_prompt(prompt)
      scope << prompt
      self
    end
  end
end
