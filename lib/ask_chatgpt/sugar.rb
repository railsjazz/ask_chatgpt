module AskChatgpt
  module Sugar

    def debug!(mode = :on)
      AskChatGPT.debug = mode == :on
    end

    def sync!
      AskChatGPT.mode = :sync
    end

    def async!
      AskChatGPT.mode = :async
    end

    def on!(feature)
      case feature
      when :markdown
        AskChatGPT.markdown = true
      when :debug
        AskChatGPT.debug = true
      when :async
        AskChatGPT.mode = :async
      when :sync
        AskChatGPT.mode = :sync
      else
        raise InputError, "Unknown feature: #{feature}"
      end
    end

    def off!(feature)
      case feature
      when :markdown
        AskChatGPT.markdown = false
      when :debug
        AskChatGPT.debug = false
      when :async
        AskChatGPT.mode = :sync
      when :sync
        AskChatGPT.mode = :async
      else
        raise InputError, "Unknown feature: #{feature}"
      end
    end

  end
end
