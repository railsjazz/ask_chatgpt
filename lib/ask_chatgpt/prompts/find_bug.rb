module AskChatgpt
  module Prompts
    class FindBug < Improve
      private def action_info
        "Locate any logic errors in the following Ruby code snippet:"
      end
    end
  end
end
