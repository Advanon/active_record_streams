# frozen_string_literal: true

require_relative '../spec/mocks/active_record/persistence'
require_relative '../spec/mocks/active_record/relation'
require_relative '../spec/mocks/active_record/base'

require_relative 'active_record_streams'

RSpec.describe ActiveRecordStreams do
  describe '.configure' do
    it 'yields configuration' do
      expect { |b| subject.configure(&b) }.to yield_control
    end
  end

  describe '.config' do
    it 'returns configuration' do
      expect(subject.config).to be_a(ActiveRecordStreams::Config)
    end
  end
end
