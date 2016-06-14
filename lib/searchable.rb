require_relative 'db_connection'

module Searchable

  def find(id)
    query = <<-SQL
      SELECT
        #{table_name}.*
      FROM
        #{table_name}
      WHERE
        #{table_name}.id = #{id}
    SQL
    parse_all(DBConnection.execute(query)).first
  end

  def find_by_sql(query)
    parse_all(DBConnection.execute(query))
  end

  def where(params)
    where_line_array = params.keys.map { |col| "#{col} = ?" }
    where_line = where_line_array.join(' AND ')

    query = <<-SQL
      SELECT
        #{table_name}.*
      FROM
        #{table_name}
      WHERE
        #{where_line}
    SQL

    parse_all(DBConnection.execute(query, params.values))
  end

end
