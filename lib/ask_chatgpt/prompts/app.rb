module AskChatgpt
  module Prompts
    class App < Base
      def content
        [
          general_info,
          version_info,
          database_info
        ].compact_blank.join(", ")
      end

      private

      def general_info
        "I have a Ruby on Rails Application"
      end

      def database_info
        db_name = ActiveRecord::Base.connection_db_config.configuration_hash[:adapter] rescue nil
        "Database: #{db_name}" if db_name
      end

      def version_info
        "Rails Version #{Rails.version}, Ruby Version: #{RUBY_VERSION}"
      end
    end
  end
end
