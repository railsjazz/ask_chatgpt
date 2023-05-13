module AskChatgpt
  module Prompts
    class WithCode < Base

      attr_reader :args

      def initialize(*args)
        @args = args
      end

      def content
        code_info.reject { |v| v.blank? }.join("\n")
      end

      private

      def code_info
        args.compact.map do |arg|
          AskChatGPT::Helpers.extract_source(arg)
        end
      end

    end
  end
end
