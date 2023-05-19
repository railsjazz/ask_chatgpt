require_relative "sugar"
require_relative "prompts/base"
require_relative "prompts/improve"
require_relative "default_behavior"
require_relative "voice"

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

    def self.call
      client = OpenAI::Client.new(access_token: AskChatGPT.access_token)
      AskChatgpt::Executor.new(client)
    end

    def speak
      puts "Voice input is not enabled (docs: https://github.com/railsjazz/ask_chatgpt)" unless AskChatGPT.voice_enabled
      puts "Audio device ID is not configured (docs: https://github.com/railsjazz/ask_chatgpt)" unless AskChatGPT.audio_device_id

      AskChatgpt::VoiceFlow::Voice.new.run
    end
    alias_method :s, :speak

    def initialize(client)
      @scope   = AskChatGPT.included_prompts.dup
      @client  = client
      @spinner = TTY::Spinner.new(format: :classic)
      @cursor  = TTY::Cursor
    end

    def inspect
      return if @executed
      @executed = true

      pp(executor_parameters) if AskChatGPT.debug
      call_with_validations do
        case AskChatGPT.mode
        when :async
          call_async
        else
          call_sync
        end
      end
      nil
    rescue SystemExit, SignalException, InputError, NoMethodError => e
      puts e.message
    rescue StandardError => e
      puts e.message
      puts e.backtrace.take(5).join("\n")
    rescue Exception => e
      puts e.message
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
      spinner&.stop if spinner&.spinning?
      if AskChatGPT.markdown
        result = content.compact.join
        shift = result.split("\n").size == 1 ? 1 : result.split("\n").size + 1
        # re-draw the screen
        # go back to the top by the number of new lines previously printed
        print cursor.clear_lines(shift, :up)
        # print cursor.restore
        # print cursor.down
        # print cursor.clear_screen_down
        # $content = content.compact.join
        puts(TTY::Markdown.parse(result))
      else
        # nothing, content is already printed in the stream
      end
      nil
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
      nil
    end

    def executor_parameters
      @executor_parameters ||= {
        model: model,
        temperature: temperature,
        max_tokens: max_tokens,
        messages: scope.map { |e| { role: "user", content: e.content } }.reject { |e| e[:content].blank? },
      }.reject { |_, v| v.blank? }
    end

    def temperature
      # see RandomFact class for example
      new_temperature = scope.map { |e| e.class.const_get("TEMPERATURE") rescue nil }.compact.first
      new_temperature.presence || AskChatGPT.temperature
    end

    def model
      AskChatGPT.model
    end

    def max_tokens
      AskChatGPT.max_tokens
    end
  end
end
