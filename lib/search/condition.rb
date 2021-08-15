# frozen_string_literal: true

module Search
  # A data container to hold all terms needed for the search
  Condition = Struct.new(:level, :option, :term, :value) do
    # an option overwrite method to map int 1 or 2 to 'users' or 'tickets'
    def option=(new_option)
      case new_option
      when 1
        self[:option] = 'users'
      when 2
        self[:option] = 'tickets'
      end
    end

    # reset all serach conditons by re-initialising
    def reset
      initialize
    end

    # check if all needed search terms are provided
    def valid?
      !option.nil? && !term.nil? && !value.nil?
    end

    # print all search conditons/terms
    def print
      %w[option term value].each do |condition|
        puts "#{condition}: #{self[condition]}"
      end
    end
  end
end
