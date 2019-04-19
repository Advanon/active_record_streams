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

      def initialize(
        topic_arn:,
        table_name: ANY_TABLE,
        ignored_tables: [],
        overrides: {}
      )
        @topic_arn = topic_arn
        @table_name = table_name
        @ignored_tables = ignored_tables
        @overrides = overrides
      end

      ##
      # @param [String] table_name
      # @param [ActiveRecordStreams::Message] message

      def publish(table_name, message)
        return unless (any_table? && allowed_table?(table_name)) ||
                      table_name == @table_name

        client.publish(@topic_arn, message.json, @overrides)
      end

      private

      def any_table?
        @table_name == ANY_TABLE
      end

      def allowed_table?(table_name)
        !@ignored_tables.include?(table_name)
      end

      def client
        @client ||= SnsClient.new
      end
    end
  end
end
