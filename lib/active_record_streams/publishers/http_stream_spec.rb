# frozen_string_literal: true

require_relative 'http_stream'

RSpec.describe ActiveRecordStreams::Publishers::HttpStream do
  let(:url) { 'http://hello.world' }
  let(:headers) { { 'Authorization' => 'Bearer hello' } }
  let(:desired_table_name) { '*' }
  let(:actual_table_name) { 'lovely_records' }
  let(:ignored_tables) { [] }

  let(:request) { double('body=': nil, request: nil) }
  let(:http_client) { double('body=': nil, request: nil) }
  let(:message) { double(json: '{}') }

  subject do
    described_class.new(
      url: url,
      headers: headers,
      table_name: desired_table_name,
      ignored_tables: ignored_tables
    )
  end

  before do
    allow(Net::HTTP::Post).to receive(:new).and_return(request)
    allow(Net::HTTP).to receive(:new).and_return(http_client)
  end

  describe '#publish' do
    context 'any table' do
      it 'sends event to a http target' do
        subject.publish(actual_table_name, message)

        expect(request).to have_received(:body=).with(message.json)
        expect(http_client).to have_received(:request).with(request)
      end
    end

    context 'specific table' do
      let(:desired_table_name) { actual_table_name }

      it 'sends event to a http target' do
        subject.publish(actual_table_name, message)

        expect(request).to have_received(:body=).with(message.json)
        expect(http_client).to have_received(:request).with(request)
      end
    end

    context 'non-matching table' do
      let(:desired_table_name) { 'another_table' }

      it 'does not send event to a http target' do
        subject.publish(actual_table_name, message)

        expect(request).not_to have_received(:body=).with(message.json)
        expect(http_client).not_to have_received(:request).with(request)
      end
    end

    context 'blacklisted table' do
      let(:ignored_tables) { [actual_table_name] }

      it 'does not send event to a http target' do
        subject.publish(actual_table_name, message)

        expect(request).not_to have_received(:body=).with(message.json)
        expect(http_client).not_to have_received(:request).with(request)
      end
    end
  end
end
