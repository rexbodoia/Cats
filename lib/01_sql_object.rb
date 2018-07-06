require_relative 'db_connection'
require 'active_support/inflector'
require 'byebug' 
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    return @columns if @columns
    @columns = DBConnection.execute2(<<-SQL)
      SELECT 
      *
      FROM
      #{table_name}
      SQL
    @columns = @columns.first
    @columns.map! { |key| key.to_sym }
  end

  def self.finalize!
    self.columns.each do |column|
      define_method(column) do 
        self.attributes[column]
      end
      define_method("#{column}=") do |value|
        self.attributes[column] = value
      end
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name || self.to_s.tableize
  end

  def self.all
    result = DBConnection.execute(<<-SQL)
      SELECT
        *
      FROM
        #{table_name}
    SQL
    self.parse_all(result)
  end
  
  def self.parse_all(results)
    result = []
    results.each do |hash|
      result << self.new(hash) 
    end
    result
  end

  def self.find(id)
    result = DBConnection.execute(<<-SQL, id)
      SELECT
        *
      FROM
        #{table_name}
      WHERE
        #{table_name}.id = ?
    SQL
    self.parse_all(result).first
  end

  def initialize(params = {})
    params.each do |attr_name, value|
      attr_name = attr_name.to_sym
      if self.class.columns.include?(attr_name)
        self.send("#{attr_name}=", value)
      else
        raise "unknown attribute \'#{attr_name}\'"
      end
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    # ...
  end

  def insert
    # ...
  end

  def update
    # ...
  end

  def save
    # ...
  end
end
