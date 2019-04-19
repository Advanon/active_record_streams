# frozen_string_literal: true

require_relative 'kinesis_client'

RSpec.describe ActiveRecordStreams::Publishers::KinesisClient do
  let(:stream_name) { 'lovely-stream' }
  let(:partition_key) { 'abcdefghihklmopqrstuvwxyz' }
  let(:data) { 'dummy data' }
  let(:overrides) { {} }

  let(:aws_kinesis_client) { double }

  before do
    allow(Aws::Kinesis::Client).to receive(:new).and_return(aws_kinesis_client)
  end

  describe '#publish' do
    subject do
      described_class.new.publish(stream_name, partition_key, data, overrides)
    end

    context 'no overrides' do
      it 'calls aws sdk' do
        expect(aws_kinesis_client).to receive(:put_record).with(
          stream_name: stream_name,
          data: data,
          partition_key: partition_key
        )

        subject
      end
    end

    context 'overrides' do
      let(:overrides) { { additional_param: true } }

      it 'calls aws sdk' do
        expect(aws_kinesis_client).to receive(:put_record).with(
          stream_name: stream_name,
          data: data,
          partition_key: partition_key,
          additional_param: true
        )

        subject
      end
    end
  end
end
