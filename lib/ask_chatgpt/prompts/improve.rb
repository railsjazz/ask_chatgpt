module AskChatgpt
  module Prompts
    class Improve < Base
      attr_reader :method

      def initialize(method)
        @method = method
      end

      def content
        [
          action_info,
          method_info,
        ].compact_blank.join("\n")
      end

      private

      def action_info
        "Improve this code:"
      end

      def method_info
        "Method source\n: #{method.source}"
      end

    end
  end
end
