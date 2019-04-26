# frozen_string_literal: true

require 'securerandom'

module ActiveRecordStreams
  class Message
    def initialize(table_name, action_type, old_image, new_image)
      @table_name = table_name
      @action_type = action_type
      @old_image = old_image || new_image
      @new_image = new_image
    end

    def self.from_json(json)
      parsed_json = JSON.parse(json)

      new(
        parsed_json['TableName'],
        parsed_json['ActionType'],
        parsed_json['OldImage'],
        parsed_json['NewImage']
      )
    end

    def json
      {
        EventID: SecureRandom.uuid,
        TableName: @table_name,
        ActionType: @action_type,
        OldImage: @old_image,
        NewImage: @new_image
      }.to_json
    end
  end
end
