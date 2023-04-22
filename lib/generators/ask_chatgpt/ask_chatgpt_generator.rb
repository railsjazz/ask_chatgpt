class AskChatgptGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('../templates', __FILE__)

  def copy_initializer
    template 'template.rb', 'config/initializers/ask_chatgpt.rb'
  end
end
