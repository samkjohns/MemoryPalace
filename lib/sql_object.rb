require_relative 'db_connection'
require_relative 'searchable'
require_relative 'associatable'
require 'active_support/inflector'

class SQLObject

  extend Searchable
  extend Associatable

  def self.columns
    query = <<-SQL
      SELECT
        *
      FROM
        #{table_name}
    SQL
    @columns ||= DBConnection.execute2(query).first.map(&:to_sym)
  end

  def self.finalize!
    columns.each do |column_name|
      define_method(column_name) do
        attributes[column_name]
      end

      define_method("#{column_name}=") do |value|
        attributes[column_name] = value
      end
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name || self.to_s.downcase.tableize
  end

  def self.all
    query = <<-SQL
      SELECT
        #{table_name}.*
      FROM
        #{table_name}
    SQL
    parse_all DBConnection.execute(query)
  end

  def self.parse_all(results)
    models = []
    results.each do |attr_hash|
      models << self.new(attr_hash)
    end
    models
  end

  def initialize(params = {})
    params.each do |name, value|
      unless self.class.columns.include?(name.to_sym)
        raise Exception.new("unknown attribute '#{name}'")
      end
      self.send("#{name}=".to_sym, value)
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    self.class.columns.map do |col|
      self.send col
    end
  end

  def insert
    question_marks = attributes.map { "?" } .join(', ')

    query = <<-SQL
      INSERT INTO
        #{self.class.table_name} (#{self.class.columns[1..-1].join(', ')})
      VALUES
        (#{question_marks})
    SQL

    DBConnection.execute(query, *attribute_values[1..-1])
    attributes[:id] = DBConnection.last_insert_row_id
  end

  def update
    set_line_array = self.class.columns[1..-1].map { |col| "#{col} = ?" }
    set_line = set_line_array.join(', ')

    query = <<-SQL
      UPDATE
        #{self.class.table_name}
      SET
        #{set_line}
      WHERE
        id = ?
    SQL

    DBConnection.execute(query, *attribute_values[1..-1], self.id)
  end

  def save
    id.nil? ? insert : update
  end

end
