# frozen_string_literal: true

require_relative 'config'

RSpec.describe ActiveRecordStreams::Config do
  describe 'attr accessors' do
    context 'initial values' do
      it 'returns correct initial values' do
        expect(subject.aws_region).to eq(nil)
        expect(subject.aws_access_key_id).to eq(nil)
        expect(subject.aws_secret_access_key).to eq(nil)
        expect(subject.streams).to eq([])
      end
    end

    context 'attr setters' do
      it 'sets and returns proper values' do
        subject.aws_region = 'test-region'
        expect(subject.aws_region).to eq('test-region')

        subject.aws_access_key_id = 'test-access-key-id'
        expect(subject.aws_access_key_id).to eq('test-access-key-id')

        subject.aws_secret_access_key = 'test-secret-access-key'
        expect(subject.aws_secret_access_key).to eq('test-secret-access-key')

        subject.streams << 'test-stream'
        expect(subject.streams).to eq(['test-stream'])
      end
    end
  end
end
