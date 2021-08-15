# frozen_string_literal: true

RSpec.describe CommandHandler do
  let(:users_data_file) { 'spec/fixtures/users.json' }
  let(:tickets_data_file) { 'spec/fixtures/tickets.json' }
  let(:search_engine) { Search::Engine.new }
  let(:command) { '1' }

  before do
    allow_any_instance_of(Search::Engine).to receive(:preload_data)
    allow($stdout).to receive(:puts)
  end

  describe '.execute' do
    subject { described_class.execute(command, search_engine) }

    context 'when command is quit' do
      let(:command) { 'quit' }

      it 'exit the program' do
        expect(Kernel).to receive(:exit).with(1)
        subject
      end
    end

    context 'when command is not quit' do
      context 'when search level option is not set' do
        context 'when command is 1' do
          let(:command) { '1' }

          it 'set search level option to 1' do
            subject
            expect(search_engine.conditions.level).to eq(1)
          end
        end

        context 'when command is 2' do
          let(:command) { '2' }

          it 'list searchable fields' do
            expect(described_class).to receive(:list_searchable_fields)
            subject
          end
        end

        context 'when command is anything else' do
          let(:command) { 'anything else' }

          it 'reset search engine' do
            expect(described_class).to receive(:reset_search_engine)
            subject
          end
        end
      end

      context 'when search level option is set' do
        let(:command) { '1' }
        before { search_engine.conditions.level = 1 }

        it 'run the search engine' do
          expect(described_class).to receive(:operate_searh_engine).with(command, search_engine, false)
          subject
        end
      end
    end
  end

  describe '.operate_searh_engine' do
    subject { described_class.operate_searh_engine(command, search_engine, true) }

    context 'when search level is 1' do
      before { search_engine.conditions.level = 1 }

      context 'when command is 1 or 2' do
        let(:command) { '2' }

        it 'set option vlaue and increment search level' do
          subject
          expect(search_engine.conditions.option).to eq('tickets')
          expect(search_engine.conditions.level).to eq(2)
        end
      end

      context 'when command is anything else' do
        let(:command) { 'anything else' }

        it 'reset search engine' do
          expect(described_class).to receive(:reset_search_engine)
          subject
        end
      end
    end

    context 'when search level is 2' do
      before { search_engine.conditions.level = 2 }
      let(:command) { 'tags' }

      it 'set search term and increment search level' do
        subject
        expect(search_engine.conditions.term).to eq(command)
        expect(search_engine.conditions.level).to eq(3)
      end
    end

    context 'when search level is 3' do
      before { search_engine.conditions.level = 3 }
      let(:command) { 'tags' }

      it 'set search value and run the search' do
        expect(search_engine).to receive(:execute)

        subject
        expect(search_engine.conditions.value).to eq(command)
      end
    end
  end

  describe '.reset_search_engine' do
    subject { described_class.reset_search_engine(command, search_engine, true) }

    it 'reset search engine and print out search options' do
      expect(search_engine).to receive(:reset)
      expect(described_class).to receive(:print_search_options)

      subject
    end
  end

  describe '.print_manual' do
    subject { described_class.print_manual(type: type) }
    before { allow($stdout).to receive(:puts).and_call_original }

    context 'when type is search' do
      let(:type) { 'search' }

      it 'print search program manual' do
        expect(described_class).to receive(:print_search_options)
        expect { subject }.to output(/Welcome to Zendesk Search!/).to_stdout
      end
    end

    context 'when type is cli' do
      let(:type) { 'cli' }

      it 'print cli tool manual instead' do
        expect(described_class).not_to receive(:print_search_options)
        expect { subject }.to output(%r{Usage: bin/search_cli \[arguments\]}).to_stdout
      end
    end
  end

  describe '.print_search_options' do
    subject { described_class.print_search_options }
    before { allow($stdout).to receive(:puts).and_call_original }

    it 'print search options for the program' do
      expect { subject }.to output(/Select Search options/).to_stdout
    end
  end

  describe '.list_searchable_fields' do
    subject { described_class.list_searchable_fields }
    before { allow($stdout).to receive(:puts).and_call_original }

    it 'list searchable fields on users or tickets data' do
      expect_any_instance_of(DataStore).to receive(:user_fields)
      expect_any_instance_of(DataStore).to receive(:ticket_fields)

      expect { subject }.to output(/Search Users with/).to_stdout
    end
  end
end
