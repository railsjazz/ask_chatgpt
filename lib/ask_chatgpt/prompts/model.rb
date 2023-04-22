module AskChatgpt
  module Prompts
    class Model < Base
      attr_reader :model

      def initialize(model)
        @model = model
      end

      def content
        [
          summary_info,
          schema_info,
          associations_info,
          instructions_info
        ].compact_blank.join("\n\n")
      end

      private

      def summary_info
        "Model: #{model.name}, table name: #{model.table_name}"
      end

      def schema_info
        "Schema: #{model.table_name}\n" +
        model.columns.map do |column|
          "#{column.name}: #{column.type}"
        end.join("\n")
      end

      def associations_info
        "#{model.name} Associations and Relations: \n" +
        model.reflections.map do |name, reflection|
          [
            "#{reflection.macro} :#{name}",
            reflection.options.inject("") { |h, (k, v)| h += "#{k}: #{v}" }
          ].join(', ')
        end.join("\n")
      end

      def instructions_info
        "Use relations and associations, pay attention to the foreign keys. Read models and their associations."
      end
    end
  end
end
