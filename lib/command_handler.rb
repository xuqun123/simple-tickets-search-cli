# frozen_string_literal: true

# A command handler to execute each user input command
module CommandHandler
  # execute a user input command
  def self.execute(command, verbose: false)
    case command.strip
    when 'quit'
      exit(1)
    else
      puts "The user input command is: #{command}" if verbose
    end
  end
end
