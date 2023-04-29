require_relative "sugar"
require_relative "prompts/base"
require_relative "prompts/improve"
require_relative "default_behavior"

Dir[File.join(__dir__, "prompts", "*.rb")].each do |file|
  require file
end

# for inspiration:
# https://www.greataiprompts.com/chat-gpt/best-coding-prompts-for-chat-gpt/

module AskChatgpt
  class InputError < StandardError; end

  class Executor
    include AskChatgpt::Sugar, AskChatgpt::DefaultBehavior

    attr_reader :scope, :client, :spinner, :cursor

    def initialize(client)
      @scope   = AskChatGPT.included_prompt.dup
      @client  = client
      @spinner = TTY::Spinner.new(format: :classic)
      @cursor  = TTY::Cursor
    end

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

    private

    def call_with_validations
      if scope.empty? || (scope.size == 1 && scope.first.is_a?(AskChatGPT::Prompts::App))
        raise InputError, "No prompts given"
      end
      print cursor.save
      spinner.auto_spin
      yield
    ensure
      spinner.stop if spinner&.spinning?
    end

    # we will collect all chunks and print them at once later with Markdown
    def call_async
      content = []
      response = client.chat(parameters: executor_parameters.merge({
        stream: proc do |chunk, _bytesize|
          spinner.stop if spinner&.spinning?
          content_part = chunk.dig("choices", 0, "delta", "content")
          content << content_part
          print content_part
        end
      }))
      if AskChatGPT.markdown
        # re-draw the screen
        # go back to the top by the number of new lines previously printed
        print cursor.clear_lines(content.compact.join.split("\n").size + 1, :up)
        # print cursor.restore
        # print cursor.down
        # print cursor.clear_screen_down
        # $content = content.compact.join
        puts(TTY::Markdown.parse(content.compact.join))
      else
        # nothing, content is already printed in the stream
      end
    end

    # wait for the whole response and print it at once
    def call_sync
      response = client.chat(parameters: executor_parameters)
      pp(response) if AskChatGPT.debug
      spinner&.stop

      if response["error"]
        puts(response["error"]["message"])
      else
        content = response.dig("choices", 0, "message", "content")
        if AskChatGPT.markdown
          puts(TTY::Markdown.parse(content))
        else
          puts(content)
        end
      end
    end

    def executor_parameters
      @executor_parameters ||= {
        model: AskChatGPT.model,
        temperature: AskChatGPT.temperature,
        max_tokens: AskChatGPT.max_tokens,
        messages: scope.map { |e| { role: "user", content: e.content } }.reject { |e| e[:content].blank? },
      }.reject { |_, v| v.blank? }
    end
  end
end
