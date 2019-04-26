# frozen_string_literal: true

require_relative 'message'

RSpec.describe ActiveRecordStreams::Message do
  let(:table_name) { 'hello_world' }
  let(:action_type) { :create }
  let(:old_image) { { 'hello' => 'world' } }
  let(:new_image) { { 'hello' => 'new world' } }
  let(:uuid) { '26f4ee2c-20ce-481f-b9f2-833bf7e51c5e' }

  subject do
    described_class.new(table_name, action_type, old_image, new_image)
  end

  before do
    allow(SecureRandom).to receive(:uuid).and_return(uuid)
  end

  describe '.from_json' do
    let(:expected_value) do
      {
        EventID: uuid,
        TableName: table_name,
        ActionType: action_type,
        OldImage: old_image,
        NewImage: new_image
      }
    end

    it 'creates a message from jsom' do
      expect(described_class.from_json(expected_value.to_json))
        .to be_a(described_class)
    end

    it 'creates a right schema from json' do
      expect(described_class.from_json(expected_value.to_json).json)
        .to eq(expected_value.to_json)
    end
  end

  describe '#json' do
    let(:expected_value) do
      {
        EventID: uuid,
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
