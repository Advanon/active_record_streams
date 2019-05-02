# frozen_string_literal: true

require_relative 'kinesis_stream'

RSpec.describe ActiveRecordStreams::Publishers::KinesisStream do
  let(:stream_name) {}
  let(:partition_key) {}
  let(:desired_table_name) { '*' }
  let(:actual_table_name) { 'lovely_records' }
  let(:ignored_tables) { [] }
  let(:overrides) { {} }
  let(:error_handler) { nil }

  let(:message) { double(json: '{}') }
  let(:kinesis_client) { double(publish: nil) }

  subject do
    described_class.new(
      stream_name: stream_name,
      table_name: desired_table_name,
      ignored_tables: ignored_tables,
      overrides: overrides,
      error_handler: error_handler
    )
  end

  before do
    allow(ActiveRecordStreams::Publishers::KinesisClient)
      .to receive(:new)
      .and_return(kinesis_client)
  end

  describe '#publish' do
    context 'any table' do
      it 'sends event to kinesis stream' do
        expect(kinesis_client).to receive(:publish) do |stream, partition_key, data, _overrides|
          expect(stream).to eq(stream_name)
          expect(partition_key).to match(/\A#{actual_table_name}-/i)
          expect(data).to eq(message.json)
        end

        subject.publish(actual_table_name, message)
      end
    end

    context 'specific table' do
      let(:desired_table_name) { actual_table_name }

      it 'sends event to a kinesis stream' do
        expect(kinesis_client).to receive(:publish) do |stream, partition_key, data, _overrides|
          expect(stream).to eq(stream_name)
          expect(partition_key).to match(/\A#{actual_table_name}-/i)
          expect(data).to eq(message.json)
        end

        subject.publish(actual_table_name, message)
      end
    end

    context 'non-matching table' do
      let(:desired_table_name) { 'another_table' }

      it 'does not send event to kinesis stream' do
        expect(kinesis_client).not_to receive(:publish)

        subject.publish(actual_table_name, message)
      end
    end

    context 'blacklisted table' do
      let(:ignored_tables) { [actual_table_name] }

      it 'does not send event to kinesis stream' do
        expect(kinesis_client).not_to receive(:publish)

        subject.publish(actual_table_name, message)
      end
    end

    context 'with overrides' do
      let(:overrides) { { 'hello' => 'world' } }

      it 'sends event to a kinesis stream' do
        expect(kinesis_client).to receive(:publish) do |stream, partition_key, data, overrides|
          expect(stream).to eq(stream_name)
          expect(partition_key).to match(/\A#{actual_table_name}-/i)
          expect(data).to eq(message.json)
          expect(overrides).to eq(overrides)
        end

        subject.publish(actual_table_name, message)
      end
    end

    context 'delivery error' do
      let(:error_handler) { Proc.new {} }

      it 'calls error handler' do
        expect(kinesis_client).to receive(:publish) do
          raise StandardError, 'Delivery error'
        end

        expect(error_handler).to receive(:call) do |stream, table_name, message, error|
          expect(stream).to eq(subject)
          expect(table_name).to eq(actual_table_name)
          expect(message).to eq(message)
          expect(error.message).to eq('Delivery error')
        end

        subject.publish(actual_table_name, message)
      end
    end

    context 'delivery error error with error handling off' do
      let(:error_handler) { Proc.new {} }

      it 'raises exception' do
        expect(kinesis_client).to receive(:publish) do
          raise StandardError, 'Delivery error'
        end

        expect(error_handler).not_to receive(:call)

        expect { subject.publish(actual_table_name, message, handle_error: false) }
          .to raise_error(StandardError)
      end
    end
  end
end
