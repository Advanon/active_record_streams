# frozen_string_literal: true

require_relative 'version'

RSpec.describe ActiveRecordStreams::VERSION do
  it 'has a version number' do
    expect(subject).to eq('0.1.2')
  end
end
