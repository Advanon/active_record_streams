# frozen_string_literal: true

require_relative 'credentials'

RSpec.describe ActiveRecordStreams::Credentials do
  describe '#build_credentials' do
    let(:config) do
      double(
        aws_region: nil,
        aws_access_key_id: nil,
        aws_secret_access_key: nil
      )
    end

    before do
      allow(ActiveRecordStreams).to receive(:config).and_return(config)
    end

    subject { described_class.new.build_credentials }

    context 'has region config' do
      before do
        allow(config).to receive(:aws_region).and_return('eu-central-1')
      end

      it 'returns a proper config' do
        expect(subject).to eq(region: 'eu-central-1')
      end
    end

    context 'has no region config' do
      it 'returns a proper config' do
        expect(subject).to eq({})
      end
    end

    context 'has access keys config' do
      before do
        allow(config).to receive(:aws_access_key_id).and_return('access-key-id')
        allow(config).to receive(:aws_secret_access_key).and_return('secret')
      end

      it 'returns a proper config' do
        expect(subject).to eq(
          access_key_id: 'access-key-id',
          secret_access_key: 'secret'
        )
      end
    end

    context 'has no access keys config' do
      it 'returns a proper config' do
        expect(subject).to eq({})
      end
    end

    context 'has region and access key config' do
      before do
        allow(config).to receive(:aws_region).and_return('eu-central-1')
        allow(config).to receive(:aws_access_key_id).and_return('access-key-id')
        allow(config).to receive(:aws_secret_access_key).and_return('secret')
      end

      it 'returns a proper config' do
        expect(subject).to eq(
          region: 'eu-central-1',
          access_key_id: 'access-key-id',
          secret_access_key: 'secret'
        )
      end
    end

    context 'has no any config' do
      it 'returns a proper config' do
        expect(subject).to eq({})
      end
    end
  end
end
