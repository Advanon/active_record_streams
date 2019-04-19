# frozen_string_literal: true

require 'aws-sdk'

module ActiveRecordStreams
  module Publishers
    class SnsClient
      def publish(topic_arn, message, overrides = {})
        client.publish(
          topic_arn: topic_arn,
          message: message,
          **overrides
        )
      end

      private

      def client
        @client ||= Aws::SNS::Client.new(
          ::ActiveRecordStreams::Credentials.new.build_credentials
        )
      end
    end
  end
end
