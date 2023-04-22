module AskChatgpt
  module Prompts
    class CodeReview < Improve
      private def action_info
        "Analyze the given Ruby code for code smells and suggest improvements:"
      end
    end
  end
end
