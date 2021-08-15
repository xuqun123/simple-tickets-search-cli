# frozen_string_literal: true

RSpec.describe Search::Condition do
  subject { described_class.new }

  describe '#option=' do
    context 'when new_option is 1' do
      it 'set users option value to be users' do
        subject.option = 1
        expect(subject.option).to eq('users')
      end
    end

    context 'when new_option is 2' do
      it 'set users option value to be tickets' do
        subject.option = 2
        expect(subject.option).to eq('tickets')
      end
    end
  end

  describe '#reset' do
    before do
      subject.option = 1
      subject.term = '_id'
    end

    it 're-initialise the search condition instance' do
      expect(subject.option).not_to be_nil
      expect(subject.term).not_to be_nil

      subject.reset
      expect(subject.option).to be_nil
      expect(subject.term).to be_nil
    end
  end

  describe '#valid?' do
    context 'when missing search conditions' do
      it 'return false' do
        expect(subject.valid?).to be(false)
      end
    end

    context 'when all search conditions are provided' do
      before do
        subject.option = 1
        subject.term = '_id'
        subject.value = '123'
      end

      it 'return false' do
        expect(subject.valid?).to be(true)
      end
    end
  end

  describe '#print' do
    before do
      subject.option = 1
      subject.term = '_id'
    end

    it 'print out search conditions properly' do
      expect { subject.print }.to output("option: users\nterm: _id\nvalue: \n").to_stdout
    end
  end
end
