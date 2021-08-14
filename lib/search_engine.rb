# frozen_string_literal: true

SearchCondition = Struct.new(:level, :option, :term, :value) do
  def option=(new_option)
    case new_option
    when 1
      self[:option] = 'users'
    when 2
      self[:option] = 'tickets'
    end
  end

  def reset
    initialize
  end

  def valid?
    !option.nil? && !term.nil? && !value.nil?
  end

  def print
    %w[option term value].each do |condition|
      puts "#{condition}: #{self[condition]}"
    end
  end
end

class SearchEngine
  attr_reader :conditions, :results

  def initialize
    @conditions = SearchCondition.new
    @results = []
    preload_data
  end

  def preload_data
    # pre-load users and tickets data into class variables
    DataStore.insert_data('user', 'data/users.json')
    DataStore.insert_data('ticket', 'data/tickets.json')
  end

  def reset
    @conditions.reset
    @results = []
  end

  def execute
    look_up
    print_results
    reset
  end

  def look_up
    raise 'Missing search data!' unless @conditions.valid?

    data = DataStore.send(@conditions.option)
    is_array_term = is_array_term?(data, @conditions.term)

    @results = data.select do |d|
      if is_array_term
        # run an array search if the search term is an array field
        values = @conditions.value.split(',').map(&:strip)
        values.all? { |value| d[@conditions.term].include?(value) }
      else
        # run a normal value match search instead
        d[@conditions.term].to_s == @conditions.value
      end
    end

    send("extra_#{@conditions.option}_data_look_up")
  end

  def extra_users_data_look_up
    return if @results.empty?

    tickets = DataStore.tickets
    @results.each do |user|
      ticket_names = tickets.select { |t| t['assignee_id'] == user['_id'] }.map { |t| t['subject'] }
      user['tickets'] = ticket_names
    end
  end

  def extra_tickets_data_look_up
    return if @results.empty?

    users = DataStore.users
    @results.each do |ticket|
      user_name = users.find { |u| u['_id'] == ticket['assignee_id'] }&.send(:[], 'name')
      ticket['assignee_name'] = user_name
    end
  end

  def is_array_term?(data, term)
    data.first&.send(:[], term)&.is_a?(Array)
  end

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
