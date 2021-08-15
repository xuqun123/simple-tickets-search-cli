# frozen_string_literal: true

require 'stringio'

module IOHelper
  def mock_stdin(inputs)
    io = StringIO.new
    inputs.compact.each { |input| io.puts input }
    io.rewind

    $stdin = io
  end
end
