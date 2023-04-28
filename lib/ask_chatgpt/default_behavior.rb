module AskChatgpt
  module DefaultBehavior
    DEFAULT_PROMPTS = [:improve, :refactor, :question, :find_bug, :code_review, :rspec_test, :unit_test, :explain]

    def with_model(*models)
      self.tap do
        models.each do |model|
          add_prompt AskChatGPT::Prompts::Model.new(model)
        end
      end
    end
    alias :with_models :with_model

    DEFAULT_PROMPTS.each do |method|
      define_method(method) do |*args|
        add_prompt(AskChatGPT::Prompts.const_get(method.to_s.camelize).new(*args))
      end
    end
    alias :ask :question
    alias :payload :question
    alias :how :question
    alias :find :question
    alias :review :code_review

    def add_prompt(prompt)
      scope << prompt
      self
    end
  end
end
