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
        "Analyze the given Ruby on Rails code for code smells and suggest improvements"
      end

      def method_info
        case method
        when ::Proc, ::Method, ::UnboundMethod
          "Method source\n: #{method.source}"
        when Module, Class, String
          str = capture_io do
            IRB.CurrentContext.main.irb_show_source(method.to_s)
          end.join("\n")
          if str.include?("locate a definition for")
            method.to_s
          else
            str
          end
        else
          raise "Not supported parameter, pass a Method object (example: method(:foo)))"
        end
      end

      # from  https://github.com/minitest/minitest/blob/master/lib/minitest/assertions.rb#L542
      def capture_io
        _synchronize do
          begin
            captured_stdout, captured_stderr = StringIO.new, StringIO.new

            orig_stdout, orig_stderr = $stdout, $stderr
            $stdout, $stderr         = captured_stdout, captured_stderr

            yield

            return captured_stdout.string, captured_stderr.string
          ensure
            $stdout = orig_stdout
            $stderr = orig_stderr
          end
        end
      end

      def _synchronize
        yield
      end

    end
  end
end
