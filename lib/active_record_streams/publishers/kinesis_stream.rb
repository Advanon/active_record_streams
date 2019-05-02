# frozen_string_literal: true

require 'aws-sdk'

module ActiveRecordStreams
  module Publishers
    class KinesisStream
      ANY_TABLE = '*'
      PARTITION_KEY_TIME_FORMAT = '%Y%m%dT%H%M%S'

      ##
      # @param [String] stream_name
      # @param [String] table_name
      # @param [Enumerable<String>] ignored_tables
      # @param [Hash] overrides
      # @param [Proc] error_handler

      def initialize(
        stream_name:,
        table_name: ANY_TABLE,
        ignored_tables: [],
        overrides: {},
        error_handler: nil
      )
        @stream_name = stream_name
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

        client.publish(@stream_name, partition_key(table_name),
                       message.json, @overrides)
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

      def partition_key(table_name)
        "#{table_name}-#{Time.now.utc.strftime(PARTITION_KEY_TIME_FORMAT)}"
      end

      def client
        @client ||= KinesisClient.new
      end
    end
  end
end
