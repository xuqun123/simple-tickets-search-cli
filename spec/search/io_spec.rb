# frozen_string_literal: true

RSpec.describe Search::IO do
  let(:input_file_path) { 'spec/fixtures/input_1.txt' }
  let(:input_data) { File.read(input_file_path) }

  describe '.stdin' do
    subject { described_class.stdin { |input| puts input } }

    let(:commands) { input_data.split }

    before { mock_stdin(commands) }
    after { $stdin = STDIN }

    it 'read data from standard input' do
      expect { subject }.to output(input_data).to_stdout
    end
  end
end
