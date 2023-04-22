module AskChatgpt
  module Prompts
    class Base
      attr_reader :str

      def initialize(str = nil)
        @str = str
      end

      def content
        str
      end
    end
  end
end
