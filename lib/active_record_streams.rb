# frozen_string_literal: true

require 'active_record_streams/version'
require 'active_record_streams/config'
require 'active_record_streams/message'
require 'active_record_streams/credentials'

require 'active_record_streams/publishers/kinesis_client'
require 'active_record_streams/publishers/kinesis_stream'
require 'active_record_streams/publishers/sns_client'
require 'active_record_streams/publishers/sns_stream'
require 'active_record_streams/publishers/http_stream'

require 'active_record_streams/extensions/active_record/persistence'
require 'active_record_streams/extensions/active_record/relation'
require 'active_record_streams/extensions/active_record/base'

module ActiveRecordStreams
  def self.configure
    yield config
  end

  def self.config
    @config ||= Config.new
  end
end
