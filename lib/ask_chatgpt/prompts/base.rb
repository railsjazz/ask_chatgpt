module AskChatgpt
  module Prompts
    class Base
      attr_reader :record

      def initialize(record = nil)
        @record = record
      end

      def content
        record
      end
    end
  end
end
