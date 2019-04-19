# frozen_string_literal: true

require_relative '../../../../spec/mocks/active_record/relation'
require_relative 'relation'

RSpec.describe ActiveRecord::Relation do
  let(:record) { double(assign_attributes: nil, save: nil, run_callbacks: nil, attributes: { 'id' => 1 }) }

  before do
    allow(subject).to receive(:where).and_return(subject)
    allow(subject).to receive(:find_each).and_return([record])
  end

  describe '#update_all' do
    it 'invokes save for each record' do
      expect(record).to receive(:assign_attributes).with(a: 'b')
      expect(record).to receive(:save).with(validate: false)

      subject.update_all(a: 'b')
    end
  end

  describe '#delete_all' do
    before do
      allow(subject).to receive(:primary_key).and_return('id')
    end

    it 'performs deletion invoking the callbacks' do
      expect(record).to receive(:run_callbacks).with(:commit).and_yield
      expect(record).to receive(:run_callbacks).with(:destroy).and_yield
      expect(ActiveRecord::Base).to receive(:transaction).and_yield

      expect(subject).to receive(:where).with('id' => 1).and_return(subject)
      expect(subject).to receive(:delete_all_without_callbacks).and_return(1)

      expect(record).to receive(:instance_variable_set).with('@destroyed', true)

      subject.delete_all
    end
  end
end
