require_relative "lib/ask_chatgpt/version"

Gem::Specification.new do |spec|
  spec.name        = "ask_chatgpt"
  spec.version     = AskChatgpt::VERSION
  spec.authors     = ["Igor Kasyanchuk", "Liubomyr Manastyretskyi"]
  spec.email       = ["igorkasyanchuk@gmail.com", "manastyretskyi@gmail.com"]
  spec.homepage    = "https://github.com/railsjazz/ask_chatgpt"
  spec.summary     = "AI-Powered Assistant Gem right in your Rails console."
  spec.description = "AI-Powered Assistant Gem right in your Rails console."
  spec.license     = "MIT"

  spec.metadata["homepage_uri"] = spec.homepage

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md", "bin/ask_chatgpt"]
  end

  spec.executables = ["ask_chatgpt"]

  spec.add_dependency "rails"
  spec.add_dependency "ruby-openai", ">= 4.0.0"
  spec.add_dependency "tty-markdown"
  spec.add_dependency "tty-spinner"
  spec.add_dependency "tty-cursor"
  spec.add_dependency "irb", ">= 1.4.3"
  spec.add_dependency "io-console"
  spec.add_development_dependency 'wrapped_print'
  spec.add_development_dependency 'pry'

  # for testing when pry-rails changes console behavior
  # spec.add_development_dependency 'pry-rails'
end
