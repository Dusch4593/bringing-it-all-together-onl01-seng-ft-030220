require 'pry'

class Dog 
  attr_accessor :name, :breed 
  attr_reader :id
  
  def initialize(id: id = nil, name: , breed: )
    @id = id
    @name = name 
    @breed = breed
  end
  
  def self.create_table 
    sql = <<-SQL
      CREATE TABLE dogs (
        id INTEGER PRIMARY KEY,
        name TEXT, 
        breed TEXT
      )
    SQL
    DB[:conn].execute(sql)
  end
  
  
  def self.drop_table 
    sql = <<-SQL
      DROP TABLE dogs
    SQL
    DB[:conn].execute(sql)
  end
  
  def save 
    if(self.id)
      self.update 
    else 
      sql = <<-SQL 
        INSERT INTO dogs (name, breed)
        VALUES(?, ?);
      SQL
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      self
    end
  end
  
  def self.create(name: , breed: )
    dog = Dog.new(name: name, breed: breed)
    dog.save 
    dog
  end

  
  def update
    sql = <<-SQL 
      UPDATE dogs 
      SET name = ?, breed = ?
      WHERE id = ?;
    SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
  
  def self.new_from_db(row) 
    # returns an array representing the newly created Dog data
    dog = self.new(id: row[0], name: row[1], breed: row[2])
  end
  
  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * 
      FROM dogs 
      WHERE dogs.id = ?;
    SQL
    result = DB[:conn].execute(sql, id)[0]
    new_dog = self.new_from_db(result)
  end
  
  def self.find_or_create_by(name: , breed: )
    # run a query using the keyword arguments provided and store in result
    result = DB[:conn].execute("SELECT * FROM dogs WHERE dogs.name = ? AND dogs.breed = ?", name, breed)
    
    # if the results are empty, create a new Dog; otherwise, return the correct dog
    result.empty? ? self.create(name: name, breed: breed) : dog = self.new_from_db(result[0])
  end
  
  def self.find_by_name(name)
    result = DB[:conn].execute("SELECT * FROM dogs WHERE dogs.name = ?", name)[0]
    
    dog = self.new_from_db(result)
  end
end