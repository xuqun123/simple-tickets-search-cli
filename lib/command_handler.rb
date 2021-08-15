# frozen_string_literal: true

# A command handler to execute each user input command
module CommandHandler
  # process a user input command
  def self.execute(command, search_engine, verbose: false)
    cmd = command.strip

    if cmd == 'quit'
      exit(1)
    elsif search_engine.conditions.level.nil? # perform level 1 actions if search level condition is not set
      case cmd
      when '1'
        puts 'Select 1) Users or 2) Tickets'
        search_engine.conditions.level = 1
      when '2'
        list_searchable_fields
      else
        reset_search_engine(cmd, search_engine, verbose)
      end
    else
      # operate on search engine if search level condition is set
      operate_searh_engine(cmd, search_engine, verbose)
    end
  end

  # manipulate search conditions and exectue search engine if necessary
  def self.operate_searh_engine(command, search_engine, verbose)
    case search_engine.conditions.level
    when 1
      case command
      when '1', '2'
        search_engine.conditions.option = command.to_i
        search_engine.conditions.level += 1
        puts 'Enter Search term'
      else
        reset_search_engine(command, search_engine, verbose)
      end
    when 2
      search_engine.conditions.term = command
      search_engine.conditions.level += 1
      puts 'Enter Search value'
    when 3
      search_engine.conditions.value = command
      if verbose
        puts '[LOG] The search condtions are: '
        search_engine.conditions.print
      end

      puts "Searching #{search_engine.conditions.option} for #{search_engine.conditions.term}" \
           " with a value of #{search_engine.conditions.value}:"

      # invoke search engine to run the search
      search_engine.execute
    end
  end

  # reset the status of search engine
  def self.reset_search_engine(command, search_engine, verbose)
    puts "[LOG] The command is invalid: #{command}" if verbose
    # print out search options again if the command is not valid
    search_engine.reset
    print_search_options
  end

  # print out the initial user prompt info
  def self.print_search_options
    puts 'Select Search options:'
    puts ' * Press 1 to search Zendesk'
    puts ' * Press 2 to view a list of searchable fields'
    puts " * Type 'quit' to exit the program\n\n"
  end

  # display all search fields for users and tickets data
  def self.list_searchable_fields
    puts '---------------------------------'
    puts 'Search Users with'
    puts DataStore.instance.user_fields
    puts '---------------------------------'
    puts 'Search Tickets with'
    puts DataStore.instance.ticket_fields
  end
end
