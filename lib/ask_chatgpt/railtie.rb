module AskChatgpt
  class Railtie < ::Rails::Railtie
    console do
      TOPLEVEL_BINDING.eval('self').extend AskChatGPT::ConsoleMethods
    end
  end
end
