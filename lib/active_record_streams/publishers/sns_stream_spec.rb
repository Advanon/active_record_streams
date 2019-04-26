# frozen_string_literal: true

require_relative 'sns_stream'

RSpec.describe ActiveRecordStreams::Publishers::SnsStream do
  let(:topic_arn) { 'arn::some-topic-arn' }
  let(:desired_table_name) { '*' }
  let(:actual_table_name) { 'lovely_records' }
  let(:ignored_tables) { [] }
  let(:overrides) { {} }
  let(:error_handler) { nil }

  let(:message) { double(json: '{}') }
  let(:sns_client) { double(publish: nil) }

  subject do
    described_class.new(
      topic_arn: topic_arn,
      table_name: desired_table_name,
      ignored_tables: ignored_tables,
      overrides: overrides,
      error_handler: error_handler
    )
  end

  before do
    allow(ActiveRecordStreams::Publishers::SnsClient)
      .to receive(:new)
      .and_return(sns_client)
  end

  describe '#publish' do
    context 'any table' do
      it 'sends event to sns' do
        expect(sns_client).to receive(:publish) do |topic_arn, data, _overrides|
          expect(topic_arn).to eq(topic_arn)
          expect(data).to eq(message.json)
        end

        subject.publish(actual_table_name, message)
      end
    end

    context 'specific table' do
      let(:desired_table_name) { actual_table_name }

      it 'sends event to sns' do
        expect(sns_client).to receive(:publish) do |topic_arn, data, _overrides|
          expect(topic_arn).to eq(topic_arn)
          expect(data).to eq(message.json)
        end

        subject.publish(actual_table_name, message)
      end
    end

    context 'non-matching table' do
      let(:desired_table_name) { 'another_table' }

      it 'does not send event to sns' do
        expect(sns_client).not_to receive(:publish)

        subject.publish(actual_table_name, message)
      end
    end

    context 'blacklisted table' do
      let(:ignored_tables) { [actual_table_name] }

      it 'does not send event to sns' do
        expect(sns_client).not_to receive(:publish)

        subject.publish(actual_table_name, message)
      end
    end

    context 'with overrides' do
      let(:overrides) { { 'hello' => 'world' } }

      it 'sends event to a sns' do
        expect(sns_client).to receive(:publish) do |topic_arn, data, overrides|
          expect(topic_arn).to eq(topic_arn)
          expect(data).to eq(message.json)
          expect(overrides).to eq(overrides)
        end

        subject.publish(actual_table_name, message)
      end
    end

    context 'delivery error' do
      let(:error_handler) { Proc.new {} }

      it 'calls error handler' do
        expect(sns_client).to receive(:publish) do
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
  end
end
