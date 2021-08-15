# frozen_string_literal: true

module Search
  # A runner to execute the search engine
  class Runner
    # search cli flag options
    HELP_FLAGS = %w[-h --help].freeze
    VERBOSE_FLAGS = %w[-v --verbose].freeze

    attr_reader :verbose, :search_engine

    # a processor to get the relevant actions based on a given arguments list
    # arguments: Array[string] - an arguments list getting from ARGV via CLI
    def self.process(arguments = [])
      # print out help manual
      unless (arguments & HELP_FLAGS).empty?
        CommandHandler.print_manual(type: 'cli')
        return
      end

      # initiate STDIN to actively read user input
      new(verbose: !(arguments & VERBOSE_FLAGS).empty?).run
    end

    # verbose: boolean - a flag to provide more helping messages to STDOUT
    def initialize(verbose: false)
      @verbose = verbose
      @search_engine = Engine.new
    end

    # run the search engine from STDIN
    def run
      CommandHandler.print_manual
      # execute each given command from STDIN
      IO.stdin { |command| CommandHandler.execute(command, @search_engine, verbose: @verbose) }
    rescue StandardError => e
      puts "[Running error]: #{e}"
    end
  end
end
