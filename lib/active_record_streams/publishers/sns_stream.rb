# frozen_string_literal: true

module ActiveRecordStreams
  module Publishers
    class SnsStream
      ANY_TABLE = '*'

      ##
      # @param [String] topic_arn
      # @param [String] table_name
      # @param [Enumerable<String>] ignored_tables
      # @param [Hash] overrides
      # @param [Proc] error_handler

      def initialize(
        topic_arn:,
        table_name: ANY_TABLE,
        ignored_tables: [],
        overrides: {},
        error_handler: nil
      )
        @topic_arn = topic_arn
        @table_name = table_name
        @ignored_tables = ignored_tables
        @overrides = overrides
        @error_handler = error_handler
      end

      ##
      # @param [String] table_name
      # @param [ActiveRecordStreams::Message] message
      # @param [Boolean] handle_error

      def publish(table_name, message, handle_error: true)
        return unless (any_table? && allowed_table?(table_name)) ||
                      table_name == @table_name

        client.publish(@topic_arn, message.json, @overrides)
      rescue StandardError => e
        raise e unless call_error_handler?(handle_error)

        @error_handler.call(self, table_name, message, e)
      end

      private

      def any_table?
        @table_name == ANY_TABLE
      end

      def allowed_table?(table_name)
        !@ignored_tables.include?(table_name)
      end

      def call_error_handler?(handle_error)
        @error_handler.is_a?(Proc) && handle_error
      end

      def client
        @client ||= SnsClient.new
      end
    end
  end
end
