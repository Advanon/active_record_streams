# frozen_string_literal: true

module ActiveRecordStreams
  class Message
    def initialize(table_name, action_type, old_image, new_image)
      @table_name = table_name
      @action_type = action_type
      @old_image = old_image || new_image
      @new_image = new_image
    end

    def json
      {
        TableName: @table_name,
        ActionType: @action_type,
        OldImage: @old_image,
        NewImage: @new_image
      }.to_json
    end
  end
end
