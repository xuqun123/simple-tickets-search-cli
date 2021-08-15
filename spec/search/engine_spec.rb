# frozen_string_literal: true

RSpec.describe Search::Engine do
  subject { described_class.new }
  before do
    allow_any_instance_of(described_class).to receive(:preload_data)
  end

  describe '#new' do
    it { is_expected.to be_an_instance_of(Search::Engine) }

    it 'initialize with a search_condition' do
      expect_any_instance_of(described_class).to receive(:preload_data)

      subject
      expect(subject.conditions).to be_an_instance_of(Search::Condition)
      expect(subject.results).to eq([])
    end
  end

  describe '#preload_data' do
    before do
      allow_any_instance_of(described_class).to receive(:preload_data).and_call_original
    end

    it 'preload data using DataStore#insert_data method' do
      expect_any_instance_of(DataStore).to receive(:insert_data).twice
      subject
    end
  end

  describe '#reset' do
    before do
      subject.conditions.term = '_id'
      subject.instance_variable_set(:@results, [{ _id: 1, name: 'Ingrid Wagner' }])
    end

    it 'reset all instance variables' do
      expect(subject.conditions.term).not_to be_nil
      expect(subject.results).not_to be_empty

      subject.reset
      expect(subject.conditions.term).to be_nil
      expect(subject.results).to be_empty
    end
  end

  describe '#execute' do
    it 'take sets of actions' do
      expect_any_instance_of(described_class).to receive(:look_up)
      expect_any_instance_of(described_class).to receive(:print_results)
      expect_any_instance_of(described_class).to receive(:reset)

      subject.execute
    end
  end

  describe '#look_up' do
    context 'when search conditions are not valid' do
      it 'raise an error' do
        expect { subject.look_up }.to raise_error(RuntimeError)
      end
    end

    context 'when search conditions are valid' do
      let(:ticket_id) { '1a227508-9f39-427c-8f57-1b72f3fab87c' }
      let(:tags) { %w[Idaho Louisiana] }

      before do
        subject.conditions.option = 2
        subject.conditions.term = 'tags'
        subject.conditions.value = tags.join(', ')

        DataStore.instance.insert_data('tickets', 'spec/fixtures/tickets.json')
      end

      context 'when search term is an array term' do
        it 'find results properly' do
          expect_any_instance_of(described_class).to receive(:extra_tickets_data_look_up)

          subject.look_up
          results = subject.results

          expect(results.count).to eq(1)
          expect(results.first['_id']).to eq(ticket_id)
          expect(results.first['tags'].include?(tags[0])).to be(true)
          expect(results.first['tags'].include?(tags[1])).to be(true)
        end
      end

      context 'when search term is a non-array term' do
        before do
          subject.conditions.term = '_id'
          subject.conditions.value = ticket_id
        end

        it 'find results properly' do
          expect_any_instance_of(described_class).to receive(:extra_tickets_data_look_up)

          subject.look_up
          results = subject.results

          expect(results.count).to eq(1)
          expect(results.first['_id']).to eq(ticket_id)
        end
      end
    end
  end

  describe '#extra_users_data_look_up' do
    let(:user) { DataStore.instance.users.first }
    let(:ticket) { DataStore.instance.tickets.first }

    before do
      DataStore.instance.insert_data('users', 'spec/fixtures/users.json')
      DataStore.instance.insert_data('tickets', 'spec/fixtures/tickets.json')

      subject.conditions.option = 1
      subject.conditions.term = '_id'
      subject.conditions.value = user['_id']
      subject.instance_variable_set(:@results, [user])
    end

    it 'find associated ticket names for the user results' do
      subject.extra_users_data_look_up
      results = subject.results

      expect(results.count).to eq(1)
      expect(results.first['_id']).to eq(user['_id'])
      expect(results.first['tickets']).to eq([ticket['subject']])
    end
  end

  describe '#extra_tickets_data_look_up' do
    let(:user) { DataStore.instance.users.first }
    let(:ticket) { DataStore.instance.tickets.first }

    before do
      DataStore.instance.insert_data('users', 'spec/fixtures/users.json')
      DataStore.instance.insert_data('tickets', 'spec/fixtures/tickets.json')

      subject.conditions.option = 2
      subject.conditions.term = '_id'
      subject.conditions.value = ticket['_id']
      subject.instance_variable_set(:@results, [ticket])
    end

    it 'find associated assignee names for the ticket results' do
      subject.extra_tickets_data_look_up
      results = subject.results

      expect(results.count).to eq(1)
      expect(results.first['_id']).to eq(ticket['_id'])
      expect(results.first['assignee_name']).to eq(user['name'])
    end
  end

  describe '#array_term?' do
    let(:data) { [{ '_id' => 1, 'tags' => %w[tag1 tag2] }] }

    it 'return true if the search term is an array type field' do
      expect(subject.array_term?(data, 'tags')).to be(true)
    end

    it 'return true if the search term is an array type field' do
      expect(subject.array_term?(data, '_id')).to be(false)
    end
  end

  describe '#print_results' do
    context 'when results are empty' do
      it 'not print any results' do
        expect { subject.print_results }.to output(/No results found/).to_stdout
      end
    end

    context 'when results are not empty' do
      before do
        subject.instance_variable_set(:@results, [{ _id: 1, name: 'Ingrid Wagner' }])
      end

      it 'print results in a readable format' do
        expect { subject.print_results }.to output(/_id      1\nname     Ingrid Wagner\n/).to_stdout
      end
    end
  end
end
