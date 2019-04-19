# frozen_string_literal: true

require_relative '../../../../spec/mocks/active_record/base'
require_relative 'base'

RSpec.describe ActiveRecord::Base do
  let(:message) { double(new: nil) }
  let(:stream) { double(publish: nil) }
  let(:streams_config) { double(streams: [stream]) }

  before do
    allow(ActiveRecordStreams).to receive(:config).and_return(streams_config)
  end

  describe 'persistence' do
    let(:old_image) do
      {
        'hello' => 'old world',
        'world' => 'old hello'
      }
    end

    let(:new_image) do
      {
        'hello' => 'world',
        'world' => 'hello'
      }
    end

    before do
      allow(ActiveRecordStreams::Message)
        .to receive(:new)
        .with(described_class.table_name, :create, old_image, new_image)
        .and_return(message)
    end

    it 'publishes event to streams with proper data' do
      expect(stream)
        .to receive(:publish)
        .with(described_class.table_name, message)

      subject._invoke_persistent_callbacks
    end
  end
end
