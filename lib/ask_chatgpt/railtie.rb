module AskChatgpt
  class Railtie < ::Rails::Railtie
    console do
      TOPLEVEL_BINDING.eval('self').extend AskChatGPT::Console
    end
  end
end
