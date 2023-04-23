module AskChatgpt
  module Prompts
    class Explain < Improve
      private def action_info
        "Explain me this Ruby code snippet:"
      end
    end
  end
end
