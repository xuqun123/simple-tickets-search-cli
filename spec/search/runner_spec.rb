# frozen_string_literal: true

RSpec.describe Search::Runner do
  describe '.process' do
    subject { described_class.process(arguments) }

    context 'when no arguments' do
      let(:arguments) { [] }

      it 'initiate a new runner instance and invoke run method' do
        expect_any_instance_of(described_class).to receive(:run).with(no_args)
        subject
      end
    end

    context 'when -h argument is provided' do
      let(:arguments) { %w[-h] }

      it 'only return the help manual without invoking run method' do
        expect_any_instance_of(described_class).not_to receive(:run)
        expect(CommandHandler).to receive(:print_manual).with(type: 'cli')
        subject
      end
    end

    context 'when -v argument is provided' do
      let(:arguments) { %w[-v] }

      it 'run the search with \'verbose\' option' do
        expect(
          described_class
        ).to receive_message_chain(:new, :run).with(true).with(no_args)
        subject
      end
    end
  end

  describe '#new' do
    subject { described_class.new }

    it { is_expected.to be_an_instance_of(Search::Runner) }

    it 'initialize with a search_engine' do
      expect(subject.search_engine).to be_an_instance_of(Search::Engine)
      expect(subject.verbose).to be(false)
    end
  end

  describe '#run' do
    subject { described_class.new }

    context 'when a valid command is given' do
      let(:command) { '2' }

      before do
        allow(Search::IO).to receive(:stdin).and_yield(command)
      end

      it 'execute command correctly' do
        expect(CommandHandler).to receive(:print_manual).with(no_args)
        expect(CommandHandler).to receive(:execute).with(command, subject.search_engine, verbose: false)

        subject.run
      end
    end

    context 'when something went wrong' do
      let(:command) { 'a command that breaks the runner' }
      let(:err_msg) { 'Something went wrong!' }

      before do
        allow(Search::IO).to receive(:stdin).and_yield(command)
        allow(CommandHandler).to receive(:execute).with(command,
                                                        subject.search_engine, verbose: false) \
                                                  .and_raise(StandardError.new(err_msg))
      end

      it 'print a running error to stdout' do
        expect { subject.run }.to output(/#{err_msg}/).to_stdout
      end
    end
  end

  describe 'integration tests' do
    subject { described_class.new.run }

    let(:output_file_path) { "spec/fixtures/output_#{test_no}.txt" }
    let(:output_data) { File.read(output_file_path) }

    context 'test users search with _id field' do
      let(:test_no) { 1 }

      before do
        allow(Search::IO).to receive(:stdin).and_yield('1').and_yield('1').and_yield('_id').and_yield('1')
      end

      it 'return expected result' do
        expect { subject }.to output(/#{output_data}/).to_stdout
      end
    end

    context 'test tickets search with tags field' do
      let(:test_no) { 2 }

      before do
        allow(Search::IO).to receive(:stdin).and_yield('1').and_yield('2').and_yield('tags') \
                                            .and_yield('New Mexico, Şouth Carolina')
      end

      it 'return expected result' do
        expect { subject }.to output(/#{output_data}/).to_stdout
      end
    end

    context 'test search with no result found' do
      let(:test_no) { 3 }

      before do
        allow(Search::IO).to receive(:stdin).and_yield('1').and_yield('2').and_yield('type').and_yield('invalid_type')
      end

      it 'return expected result' do
        expect { subject }.to output(/#{output_data}/).to_stdout
      end
    end

    context 'test searchable fields listing' do
      let(:test_no) { 4 }

      before do
        allow(Search::IO).to receive(:stdin).and_yield('2')
      end

      it 'return expected result' do
        expect { subject }.to output(/#{output_data}/).to_stdout
      end
    end
  end
end
