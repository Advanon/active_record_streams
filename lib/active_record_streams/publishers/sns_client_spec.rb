# frozen_string_literal: true

require_relative 'sns_client'

RSpec.describe ActiveRecordStreams::Publishers::SnsClient do
  let(:topic_arn) { 'arn::some-topic-arn' }
  let(:message) { 'dummy data' }
  let(:overrides) { {} }

  let(:aws_sns_client) { double }

  before do
    allow(Aws::SNS::Client).to receive(:new).and_return(aws_sns_client)
  end

  describe '#publish' do
    subject do
      described_class.new.publish(topic_arn, message, overrides)
    end

    context 'no overrides' do
      it 'calls aws sdk' do
        expect(aws_sns_client).to receive(:publish).with(
          topic_arn: topic_arn,
          message: message
        )

        subject
      end
    end

    context 'overrides' do
      let(:overrides) { { additional_param: true } }

      it 'calls aws sdk' do
        expect(aws_sns_client).to receive(:publish).with(
          topic_arn: topic_arn,
          message: message,
          additional_param: true
        )

        subject
      end
    end
  end
end
