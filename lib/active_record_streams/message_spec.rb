# frozen_string_literal: true

require_relative 'message'

RSpec.describe ActiveRecordStreams::Message do
  let(:table_name) { 'hello_world' }
  let(:action_type) { :create }
  let(:old_image) { { 'hello' => 'world' } }
  let(:new_image) { { 'hello' => 'new world' } }

  subject do
    described_class.new(table_name, action_type, old_image, new_image)
  end

  describe '#json' do
    let(:expected_value) do
      {
        TableName: table_name,
        ActionType: action_type,
        OldImage: old_image,
        NewImage: new_image
      }.to_json
    end

    it 'represents message in json format' do
      expect(subject.json).to eq(expected_value)
    end
  end
end
