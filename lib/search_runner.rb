# frozen_string_literal: true

# A runner to execute the search engine
class SearchRunner
  # search cli flag options
  HELP_FLAGS = %w[-h --help].freeze
  VERBOSE_FLAGS = %w[-v --verbose].freeze

  attr_reader :verbose

  # a processor to get the relevant actions based on a given arguments list
  # arguments: Array[string] - an arguments list getting from ARGV via CLI
  def self.process(arguments = [])
    # print out help manual
    unless (arguments & HELP_FLAGS).empty?
      puts 'Usage: bin/search_cli [arguments]'
      puts 'no_arguments        Read user input from STDIN.'
      puts "#{HELP_FLAGS.join(', ')}          Display this help message."
      puts "#{VERBOSE_FLAGS.join(', ')}       Log debug message to standard output."
      puts 'Ctrl + D, quit      To exit the search program.'
      return
    end

    # initiate STDIN to actively read user input
    new(!(arguments & VERBOSE_FLAGS).empty?).run
  end

  # verbose: boolean - a flag to provdide more helping messages to STDOUT
  def initialize(verbose: false)
    @verbose = verbose
  end

  # run the search engine from STDIN
  def run
    # execute each given command from STDIN
    SearchIO.stdin { |command| CommandHandler.execute(command, @verbose) }
  rescue StandardError => e
    puts "[Running error]: #{e}"
  end
end
