# frozen_string_literal: true

require_relative '../../../../spec/mocks/active_record/persistence'
require_relative 'persistence'

RSpec.describe ActiveRecord::Persistence do
  let(:relation_for_destroy) { double }

  before do
    allow(subject)
      .to receive(:relation_for_destroy)
      .and_return(relation_for_destroy)
  end

  subject do
    Class.new do
      include ActiveRecord::Persistence
    end.new
  end

  describe 'destroy!' do
    it 'calls original delete_all' do
      expect(relation_for_destroy).to receive(:delete_all_without_callbacks)

      subject.destroy!
    end
  end

  describe 'destroy' do
    it 'calls original delete_all' do
      expect(relation_for_destroy).to receive(:delete_all_without_callbacks)

      subject.destroy
    end
  end
end
