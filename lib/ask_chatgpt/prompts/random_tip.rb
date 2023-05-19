module AskChatgpt
  module Prompts
    class RandomTip < Question
      TEMPERATURE = 0.8
      TOPIC = <<~TOPIC
      - Ruby
      - Ruby on Rails
      - Active Record
      - Active Record Migrations
      - Active Record Validations
      - Active Record Callbacks
      - Active Record Associations
      - Active Record Query Interface
      - Active Support Core Extensions
      - Action Mailer
      - Active Job
      - Active Storage
      - Action Cable
      - Layouts and Rendering in Rails
      - Action View Form Helpers
      - Action Controller Overview
      - Rails Routing from the Outside In
      - Rails Internationalization (I18n)
      - Testing Rails Applications
      - Securing Rails Applications
      - Debugging Rails Applications
      - Configuring Rails Applications
      - The Rails Command Line
      - The Asset Pipeline
      - Autoloading and Reloading Constants
      - Classic to Zeitwerk
      - Caching with Rails: An Overview
      - Using Rails for API-only Applications
      - Multiple Databases with Active Record
      - Ruby-related gems
      - Ruby, Rails open-source projects
    TOPIC

      def initialize(topic = TOPIC)
        prompt_text = <<~PROMPT
          Tell me interesting or useful tips,facts,method,code,etc for any of:
          #{topic}

          Answer with direct answer and no other text.
          Try to be shoft by informative and clear.
          Code examples reply in markdown format.

          Level of difficulty: ADVANCED
        PROMPT
        super(prompt_text)
      end
    end
  end
end
