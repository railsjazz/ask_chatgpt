module AskChatgpt
  module Prompts
    class Explain < Improve
      private def action_info
        "Explain me this Ruby code snippet, use Markdown for code snippets:"
      end
    end
  end
end
