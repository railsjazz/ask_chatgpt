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
        ].compact_blank.join("\n")
      end

      private

      def summary_info
        "Model: #{model.name}, table name: #{model.table_name}"
      end

      def schema_info
        "Schema: \n" +
        model.columns.map do |column|
          "#{column.name}: #{column.type}"
        end.join("\n")
      end

      def associations_info
        "Associations: \n" +
        model.reflections.map do |name, reflection|
          "#{name}: #{reflection.class}"
        end.join("\n")
      end
    end
  end
end
