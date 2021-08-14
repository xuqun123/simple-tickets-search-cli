# frozen_string_literal: true

require 'yajl'

# A command handler to execute each user input command
module CommandHandler
  # execute a user input command
  def self.execute(command, search_engine, verbose: false)
    cmd = command.strip

    if cmd == 'quit'
      exit(1)
    elsif search_engine.conditions.level.nil?
      case cmd
      when '1'
        puts 'Select 1) Users or 2) Tickets'
        search_engine.conditions.level = 1
      when '2'
        list_searchable_fields
      else
        puts "[LOG] The command is invalid: #{command}" if verbose
        # print out search options again if the command is not valid
        print_search_options
      end
    elsif search_engine.conditions.level == 1
      case cmd
      when '1'
        search_engine.conditions.option = 1
        search_engine.conditions.level += 1
        puts 'Enter Search term'
      when '2'
        search_engine.conditions.option = 2
        search_engine.conditions.level += 1
        puts 'Enter Search term'
      else
        puts "[LOG] The command is invalid: #{command}" if verbose
        # print out search options again if the command is not valid
        search_engine.reset
        print_search_options
      end
    elsif search_engine.conditions.level == 2
      search_engine.conditions.term = cmd
      search_engine.conditions.level += 1
      puts 'Enter Search value'
    elsif search_engine.conditions.level == 3
      search_engine.conditions.value = cmd

      puts "[LOG] The search condtions are: #{search_engine.conditions.print}" if verbose

      puts "Searching #{search_engine.conditions.option} for #{search_engine.conditions.term} with a value of #{search_engine.conditions.value}:"

      search_engine.execute
    end
  end

  def self.print_search_options
    puts 'Select Search options:'
    puts ' * Press 1 to search Zendesk'
    puts ' * Press 2 to view a list of searchable fields'
    puts " * Type 'quit' to exit the program\n\n"
  end

  def self.list_searchable_fields
    puts '---------------------------------'
    puts 'Search Users with'
    puts DataStore.get_user_fields
    puts '---------------------------------'
    puts 'Search Tickets with'
    puts DataStore.get_ticket_fields
  end

  def self.get_json_data(filename)
    json = File.new(filename, 'r')
    hash = Yajl::Parser.new.parse(json)
  end
end
