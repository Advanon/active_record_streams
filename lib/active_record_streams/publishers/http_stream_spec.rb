# frozen_string_literal: true

require_relative 'http_stream'

RSpec.describe ActiveRecordStreams::Publishers::HttpStream do
  let(:url) { 'http://hello.world' }
  let(:headers) { { 'Authorization' => 'Bearer hello' } }
  let(:desired_table_name) { '*' }
  let(:actual_table_name) { 'lovely_records' }
  let(:ignored_tables) { [] }
  let(:error_handler) { nil }

  let(:request) { double('body=': nil) }
  let(:response) { double(code: 200) }
  let(:http_client) { double('body=': nil, 'use_ssl=': nil, request: response) }
  let(:message) { double(json: '{}') }

  subject do
    described_class.new(
      url: url,
      headers: headers,
      table_name: desired_table_name,
      ignored_tables: ignored_tables,
      error_handler: error_handler
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

    context 'error response' do
      let(:response) { double(body: 'Error', code: 400) }
      let(:error_handler) { Proc.new {} }

      it 'calls error handler' do
        expect(error_handler).to receive(:call) do |stream, table_name, message, error|
          expect(stream).to eq(subject)
          expect(table_name).to eq(actual_table_name)
          expect(message).to eq(message)
          expect(error.message).to eq('Error')
        end

        subject.publish(actual_table_name, message)
      end
    end

    context 'https target' do
      let(:url) { 'https://hello.world' }

      it 'sends event to an https target' do
        expect(http_client).to receive(:use_ssl=).with(true)

        subject.publish(actual_table_name, message)

        expect(request).to have_received(:body=).with(message.json)
        expect(http_client).to have_received(:request).with(request)
      end
    end
  end
end
