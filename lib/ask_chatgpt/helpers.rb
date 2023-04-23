module AskChatgpt
  class Helpers
    class << self
      def extract_source(method_or_class_or_str)
        case method_or_class_or_str
        when ::Proc, ::Method, ::UnboundMethod
          method_or_class_or_str.source
        when Module, Class, String
          str = capture_io do
            IRB.CurrentContext.main.irb_show_source(method_or_class_or_str.to_s)
          end.join("\n")
          # check if source was extracted
          if str.include?("locate a definition for")
            method_or_class_or_str.to_s
          else
            str
          end
        else
          raise "Not supported parameter"
        end
      end

      private

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
