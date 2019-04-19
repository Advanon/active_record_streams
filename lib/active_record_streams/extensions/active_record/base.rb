# frozen_string_literal: true

module ActiveRecord
  Base.prepend(
    Module.new do
      def self.prepended(object)
        object.class_exec do
          before_save :capture_old_image
          after_commit :publish_event_to_streams
        end
      end

      private

      def capture_old_image
        @old_image = attributes.keys.map do |attribute|
          [attribute, attribute_was(attribute)]
        end.to_h
      end

      def publish_event_to_streams
        ActiveRecordStreams.config.streams.each do |stream|
          stream.publish(self.class.table_name, stream_message)
        end
      end

      def stream_message
        ::ActiveRecordStreams::Message.new(
          self.class.table_name, stream_action_type, @old_image, attributes
        )
      end

      def stream_action_type
        return :create if transaction_include_any_action?([:create])
        return :destroy if transaction_include_any_action?([:destroy])

        :update
      end
    end
  )
end
