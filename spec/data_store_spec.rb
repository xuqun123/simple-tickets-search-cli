# frozen_string_literal: true

RSpec.describe DataStore do
  subject { described_class.instance }
  let(:users_data_file) { 'spec/fixtures/users.json' }
  let(:tickets_data_file) { 'spec/fixtures/tickets.json' }

  describe '#new' do
    it 'invoke intialize to setup initial data' do
      expect(subject.users).to eq([])
      expect(subject.tickets).to eq([])
    end
  end

  describe '#insert_data' do
    before do
      subject.insert_data('users', users_data_file)
    end

    it 'insert data into corresponding variable' do
      expect(subject.users).not_to be_empty
    end
  end

  describe '#user_fields' do
    before do
      subject.insert_data('users', users_data_file)
    end

    it 'return all field keys of a user data' do
      expect(subject.user_fields).not_to be_empty
      expect(subject.user_fields.first).to eq('_id')
      expect(subject.user_fields.last).to eq('verified')
    end
  end

  describe '#ticket_fields' do
    before do
      subject.insert_data('tickets', tickets_data_file)
    end

    it 'return all field keys of a ticket data' do
      expect(subject.ticket_fields).not_to be_empty
      expect(subject.ticket_fields.first).to eq('_id')
      expect(subject.ticket_fields.last).to eq('tags')
    end
  end
end
