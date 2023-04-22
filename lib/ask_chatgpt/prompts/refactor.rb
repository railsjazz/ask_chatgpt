module AskChatgpt
  module Prompts
    class Refactor < Improve
      private def action_info
        "Suggest refactoring improvements for the following Ruby code:"
      end
    end
  end
end
