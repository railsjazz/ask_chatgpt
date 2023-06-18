# to make sure we have good gem version
gem "ruby-openai", '>= 4.0.0'

require_relative "ask_chatgpt/version"
require "ask_chatgpt/railtie" if defined?(Rails)
require "net/http"
require "json"
require "openai"
require "tty-markdown"
require "tty-spinner"
require "tty-cursor"
require "irb"

require "active_support/all"

require_relative "ask_chatgpt/console"
require_relative "ask_chatgpt/executor"
require_relative "ask_chatgpt/helpers"

module AskChatgpt
  ::AskChatGPT = AskChatgpt

  # async mode will use OpenAI streamming feature and will return results as they come
  mattr_accessor :mode
  @@mode = :async # or :sync

  mattr_accessor :markdown
  @@markdown = true

  mattr_accessor :debug
  @@debug = false

  # https://platform.openai.com/docs/models
  mattr_accessor :model
  @@model = "gpt-3.5-turbo"

  # https://platform.openai.com/docs/api-reference/completions/create#completions/create-temperature
  mattr_accessor :temperature
  @@temperature = 0.1

  # default max tokens will be defined by the model
  mattr_accessor :max_tokens
  @@max_tokens = nil

  # use your own API key (local per set in initializer or ENV)
  mattr_accessor :access_token
  @@access_token = ENV["OPENAI_API_KEY"]

  # this prompt is always included
  # it constain info that you have Rails app and Rails/Ruby versions, and DB adapter name
  mattr_accessor :included_prompts
  @@included_prompts = [AskChatGPT::Prompts::App.new]

  # enable voice input, requires ffmpeg to be installed and also you need to configure audio_device_id
  mattr_accessor :voice_enabled
  @voice_enabled = false

  # to get audio device ID (index in the input devices)
  # ffmpeg -f avfoundation -list_devices true -i ""
  mattr_accessor :audio_device_id
  @@audio_device_id = nil

  # max duration of audio to record
  mattr_accessor :voice_max_duration
  @@voice_max_duration = 10 # 10 seconds

  def self.setup
    yield(self)
  end

  def self.register_prompt(name, &block)
    # i want to create a module and include it into a class, with method name and code from block
    AskChatGPT::Executor.class_eval do
      define_method(name) do |*args|
        @scope << AskChatGPT::Prompts::Custom.new(*args, block)
        self
      end
    end
  end

  extend AskChatGPT::Console
end
