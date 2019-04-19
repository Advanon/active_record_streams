# frozen_string_literal: true

module ActiveRecordStreams
  class Config
    attr_accessor :aws_region, :aws_access_key_id, :aws_secret_access_key,
                  :streams

    def initialize
      @aws_region = nil
      @aws_access_key_id = nil
      @aws_secret_access_key = nil
      @streams = []
    end
  end
end
