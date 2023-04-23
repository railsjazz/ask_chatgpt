module AskChatgpt
  module Prompts
    class Custom < Base
      attr_reader :args, :block

      def initialize(*args, block)
        @args = args
        @block = block
      end

      def content
        instance_exec(*args, &block)
      end
    end
  end
end
