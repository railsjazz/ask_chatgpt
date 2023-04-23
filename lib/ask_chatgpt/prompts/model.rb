module AskChatgpt
  module Prompts
    class Model < Base
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
        "Active Record Model: #{record.name}, table name: #{record.table_name}"
      end

      def schema_info
        "Schema: #{record.table_name}\n" +
        record.columns.map do |column|
          "#{column.name}: #{column.type}"
        end.join("\n")
      end

      def associations_info
        "#{record.name} Associations and Relations: \n" +
        record.reflections.map do |name, reflection|
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
