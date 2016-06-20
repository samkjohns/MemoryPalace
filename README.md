# Memory Palace – An Object-Relational Mapping Library

Memory Palace provides an interface between a relational database and classes for Ruby applications. The library provides a class meant to be extended to provide the library's mapping conveniences. A subclass of MemoryPalaceBase represents a table in a database.

Memory Palace relies on the philosophy of convention over configuration in establishing associations between models. Mappings may be defined explicitly, but following convention by default will save the developer time.

## Configuration

Currently, Memory Palace only supports sqlite3.

In db_config.rb, assign the `DB_FILE` constant to the relative path of your database.

## Examples

A simple call to the class method `finalize!` is required to establish a model's attribute readers and writers:

```
require_relative 'lib/memory_palace_base'

class Human < MemoryPalaceBase
  finalize!
end
```

Associations may also be defined automatically through class methods:

```
class House < MemoryPalaceBase
  finalize!
  has_many :humans
end

class Human < MemoryPalaceBase
  finalize!
  belongs_to :houses
  has_many :cats
end

class Cat < MemoryPalaceBase
  finalize!
  belongs_to :human
  has_one :house, through: :human, source: :house
end
```

These allow for easy access from model to model. For example, if this represents an excerpt of our database:

```
cats
id | name | human_id
---+------+----------
 5 | Orca |   12

humans
 id | name
----+------
 12 | Sam  
```

...then this becomes possible:

```
orca = Cat.find(12) # orca ==> <#Cat> object
sam = orca.human    # sam ==> <#Human> object
```

A small sample `pokemon` SQLite3 database is included in this repository as an example.

The `has_many_through` method has not yet been implemented, but will allow the mapping of a many-to-many relationship through a join table, similarly to `has_one_through`.
