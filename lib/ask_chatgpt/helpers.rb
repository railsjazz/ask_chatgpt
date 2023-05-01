module AskChatgpt
  class Helpers
    class << self
      def extract_source(method_or_class_or_str)
        case method_or_class_or_str
        when ::Proc, ::Method, ::UnboundMethod
          method_or_class_or_str.source
        when Module, Class, String
          str = capture_io do
            init_irb unless IRB.CurrentContext
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

      class DummyInputMethod < ::IRB::InputMethod
        attr_reader :list, :line_no

        def initialize(list = [])
          super("test")
          @line_no = 0
          @list = list
        end

        def gets
          @list[@line_no]&.tap {@line_no += 1}
        end

        def eof?
          @line_no >= @list.size
        end

        def encoding
          Encoding.default_external
        end

        def reset
          @line_no = 0
        end
      end

      # https://github.com/ruby/irb/blob/95782f2cf93b4b32e51104a21a860aa4491a04bc/test/irb/test_cmd.rb#L36
      def init_irb
        conf = {}
        main = :self
        irb_path = nil
        IRB.init_config(nil)
        IRB.conf[:VERBOSE] = false
        IRB.conf[:PROMPT_MODE] = :SIMPLE
        IRB.conf.merge!(conf)
        input = DummyInputMethod.new("TestInputMethod#gets")
        irb = IRB::Irb.new(IRB::WorkSpace.new(main), input)
        irb.context.return_format = "=> %s\n"
        irb.context.irb_path = irb_path if irb_path
        IRB.conf[:MAIN_CONTEXT] = irb.context
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
