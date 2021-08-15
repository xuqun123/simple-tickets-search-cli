# frozen_string_literal: true

module Search
  # A IO module to handle user input from STDIN
  module IO
    # read from standard input and yield the value to a given block
    def self.stdin
      $stdin.each_line do |input|
        yield(input) if block_given?
      end
    end
  end
end
