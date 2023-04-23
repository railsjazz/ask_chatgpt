module AskChatgpt
  module Prompts
    class Question < Base
      def initialize(record)
        @record = record.is_a?(String) ? record : record.to_json
      end
    end
  end
end
