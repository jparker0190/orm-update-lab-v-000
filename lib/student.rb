require_relative "../config/environment.rb"

class Student
  attr_accessor :name, :grade
  attr_reader :id
  
  def initialize(id=nil, name, grade)
    @id = id
    @name = name
    @grade = grade
  end
  
  def self.create_table
    sql = <<-SQL 
    CREATE TABLE IF NOT EXISTS students (id INTEGER PRIMARY KEY, name TEXT, grade INTEGER)
    SQL
    DB[:conn].execute(sql)
  end
  
  def self.drop_table
    sql = <<-SQL
    DROP TABLE students
    SQL
    DB[:conn].execute(sql)
  end
  
  def update
    sql = <<-SQL
    UPDATE students SET name = ?, grade = ? where id =?
    SQL
    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end
  
  def save
    if self.id
      self.update
    else
    sql = <<-SQL
    INSERT INTO students (name, grade) VALUES (?,?)
    SQL
    DB[:conn].execute(sql, self.name, self.grade)
    @id = DB[:conn].execute("SELECT last_insert_rowid() from students")[0][0]
  end
end
  
  def self.create(name:, grade:)
    stud = Student.new(name, grade)
    stud.save
    stud
  end
  
  def self.new_from_db(row)
    new_stu = self.new
    new_stu.id = row[0]
    new_stu.name = row[1]
    new_stu.grade = row[2]
    new_stu
  end
  
  def self.find_by_name(name)
    sql = <<-SQL
    SELECT * from students where name = ?
    SQL
    DB[:conn].execute(sql,name).map do |row|
      self.new_from_db(row)
    end.first
  end
end
