# frozen_string_literal: true

module Search
  # A search engine to perfrom search actions
  class Engine
    attr_reader :conditions, :results

    def initialize
      @conditions = Condition.new
      @results = []
      preload_data
    end

    # pre-load users and tickets data
    def preload_data
      DataStore.instance.insert_data('users', 'data/users.json')
      DataStore.instance.insert_data('tickets', 'data/tickets.json')
    end

    # reset all search terms and results
    def reset
      @conditions.reset
      @results = []
    end

    # initiate a search
    def execute
      look_up
      print_results
      reset
    end

    # retrieve for matched users/tickets data based on searh terms
    def look_up
      raise 'Missing search data!' unless @conditions.valid?

      # get tickets/users data
      data = DataStore.instance.send(@conditions.option)
      # a flag to indicate if the search term is an arary type or not
      is_array_term = array_term?(data, @conditions.term)

      # travese all data
      @results = data.select do |d|
        if is_array_term # run an array search if the search term is an array field
          values = @conditions.value.split(',').map(&:strip)
          values.all? { |value| d[@conditions.term].include?(value) }
        else # run a normal value match search instead
          d[@conditions.term].to_s == @conditions.value
        end
      end

      # make an axtra look up to get associated ticket names or assignee names
      send("extra_#{@conditions.option}_data_look_up")
    end

    # find associated ticket names for user results
    def extra_users_data_look_up
      return if @results.empty?

      tickets = DataStore.instance.tickets
      @results.each do |user|
        ticket_names = tickets.select { |t| t['assignee_id'] == user['_id'] }.map { |t| t['subject'] }
        user['tickets'] = ticket_names
      end
    end

    # find associated assignee names for ticket results
    def extra_tickets_data_look_up
      return if @results.empty?

      users = DataStore.instance.users
      @results.each do |ticket|
        user_name = users.find { |u| u['_id'] == ticket['assignee_id'] }&.send(:[], 'name')
        ticket['assignee_name'] = user_name
      end
    end

    # check if the given search term is array type or not
    def array_term?(data, term)
      data.first&.send(:[], term)&.is_a?(Array)
    end

    # print search results in a human readable format
    def print_results
      if @results.empty?
        puts 'No results found'
        return
      end

      tab_length = @results.first.keys.max_by(&:length).length
      @results.each do |result|
        result.each do |k, v|
          printf("%-#{tab_length}s     %s\n", k, v.is_a?(Array) ? v.join(', ') : v)
        end
        puts '----------------------------------------------------------------------'
      end
    end
  end
end
