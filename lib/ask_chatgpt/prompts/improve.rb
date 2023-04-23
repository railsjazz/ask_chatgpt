module AskChatgpt
  module Prompts
    class Improve < Base

      def content
        [
          action_info,
          method_info,
        ].compact_blank.join("\n")
      end

      private

      def action_info
        "Analyze the given Ruby on Rails code for code smells and suggest improvements"
      end

      def method_info
        AskChatGPT::Helpers.extract_source(record)
      end

    end
  end
end
