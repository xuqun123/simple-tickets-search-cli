# frozen_string_literal: true

# A IO module to handle user input from STDIN
module SearchIO
  # read from standard input and yield the value to a given block
  def self.stdin
    $stdin.each_line do |input|
      yield(input) if block_given?
    end
  end
end
