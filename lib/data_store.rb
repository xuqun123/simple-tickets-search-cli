# frozen_string_literal: true

require 'yajl'
require 'singleton'

# A Singleton class as data storage to maintain users and tickets json data
class DataStore
  include Singleton

  attr_reader :users, :tickets

  def initialize
    @users = []
    @tickets = []
  end

  # insert json data for 'users' or 'tickets' type
  def insert_data(type, filename)
    json = File.new(filename, 'r')
    instance_variable_set("@#{type&.strip}".to_sym, Yajl::Parser.new.parse(json))
  end

  # get searchable fields for users
  def user_fields
    @users.first&.keys
  end

  # get searchable fields for tickets
  def ticket_fields
    @tickets.first&.keys
  end
end
