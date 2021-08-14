# frozen_string_literal: true

require 'yajl'

# A data storage class to maintain users and tickets json data
class DataStore
  @@users = []
  @@tickets = []

  def self.insert_data(type, filename)
    json = File.new(filename, 'r')

    case type&.strip
    when 'user'
      @@users = Yajl::Parser.new.parse(json)
    when 'ticket'
      @@tickets = Yajl::Parser.new.parse(json)
    else
      raise 'The data type is not supported.'
    end
  end

  def self.users
    @@users
  end

  def self.tickets
    @@tickets
  end

  def self.get_user_fields
    @@users.first&.keys
  end

  def self.get_ticket_fields
    @@tickets.first&.keys
  end
end
