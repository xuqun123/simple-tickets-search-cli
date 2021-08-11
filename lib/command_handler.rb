# frozen_string_literal: true

# A command handler to execute each user input command
module CommandHandler
  # execute a user input command
  def self.execute(command, verbose: false)
    case command.strip
    when 'quit'
      exit(1)
    when '1'
      puts 'Select 1) Users or 2) Tickets'
    when '2'
      list_searchable_fields
    else
      puts "[LOG] The command is invalid: #{command}" if verbose
      # print out search options again if the command is not valid
      print_search_options
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
    puts '_id'
    puts 'name'

    puts '---------------------------------'
    puts 'Search Tickets with'
    puts '_id'
    puts 'type'
  end
end
