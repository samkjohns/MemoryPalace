require_relative 'belongs_to_options'
require_relative 'has_many_options'

module Associatable

  def belongs_to(name, options = {})
    options = BelongsToOptions.new(name, options)
    assoc_options[name] = options

    define_method(name) do
      foreign_key_value = self.send options.foreign_key
      target_class = options.model_class
      target_table = target_class.table_name

      where_line = "#{target_table}.#{options.primary_key} = #{foreign_key_value}"

      return nil if foreign_key_value.nil?

      query = <<-SQL
        SELECT
          *
        FROM
          #{target_table}
        WHERE
          #{where_line}
      SQL

      target_class.parse_all(DBConnection.execute(query)).first
    end
  end

  def has_many(name, options = {})
    options = HasManyOptions.new(name.to_s, self.table_name, options)

    define_method(name) do
      target_class = options.model_class
      target_table = target_class.table_name

      on_line = <<-SQL
        #{self.class.table_name}.#{options.primary_key} = #{target_table}.#{options.foreign_key}
      SQL

      where_line = "#{target_table}.#{options.foreign_key} = #{id}"

      query = <<-SQL
        SELECT
          #{target_table}.*
        FROM
          #{target_table}
        JOIN
          #{self.class.table_name}
        ON
          #{on_line}
        WHERE
          #{where_line}
      SQL

      target_class.parse_all(DBConnection.execute(query))
    end

  end

  def has_one_through(name, through_name, source_name)

    define_method(name) do
      through_options = self.class.assoc_options[through_name]
      source_options = through_options.model_class.assoc_options[source_name]

      target_class = source_options.class_name.constantize
      target_table = source_options.class_name.constantize.table_name
      target_primary = source_options.primary_key

      through_class = through_options.class_name.constantize
      through_table = through_options.class_name.constantize.table_name
      foreign = source_options.foreign_key


      through_primary = through_options.primary_key

      query = <<-SQL
        SELECT
          #{target_table}.*
        FROM
          #{through_table}
        JOIN
          #{target_table}
        ON
          #{through_table}.#{foreign} = #{target_table}.#{target_primary}
        WHERE
          #{through_table}.#{through_primary} = ?
      SQL

      target_class.parse_all(DBConnection.execute(query, id)).first
    end

    def has_many_through(name, through_name, source_name)
      # Posts has_many :tags, through: :taggings
      through_options = self.class.assoc_options[through_name]
      source_options = through_options.model_class.assoc_options[source_name]

      define_method(name) do
        target_class = source_options.class_name.constantize
        target_table = source_options.class_name.constantize.table_name
        target_primary = source_options.primary_key

        through_class = through_options.class_name.constantize
        through_table = through_options.class_name.constantize.table_name
        foreign = source_options.foreign_key

        query = <<-SQL
          SELECT
            tags.*
            #{target_table}.*
          FROM
            tags
            #{target_table}
          JOIN
            taggings
            #{through_table}
          ON
            tags.id = taggings.tag_id
            #{target_table}.#{target_primary} = #{through_table}.#{foreign}
          JOIN
            posts
            #{self.class.constantize.table_name}
          ON
            posts.id = taggings.post_id
            #{self.class.constantize.table_name}.#{}
          WHERE
            posts.id = #{self.id}
        SQL
      end
    end

  end

  def assoc_options
    @assoc_options ||= {}
  end
end
