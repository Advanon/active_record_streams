# frozen_string_literal: true

require 'aws-sdk'

module ActiveRecordStreams
  module Publishers
    class KinesisClient
      def publish(stream_name, partition_key, data, overrides = {})
        client.put_record(
          stream_name: stream_name,
          data: data,
          partition_key: partition_key,
          **overrides
        )
      end

      private

      def client
        @client ||= Aws::Kinesis::Client.new(
          ::ActiveRecordStreams::Credentials.new.build_credentials
        )
      end
    end
  end
end
