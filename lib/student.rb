require 'pry'
class Student

  attr_accessor :name, :grade 
  attr_reader :id
  def initialize(name, grade, id = nil)
    @id = id
    @name = name
    @grade = grade
  end

    def self.create_table
      sql =  <<-SQL 
        CREATE TABLE IF NOT EXISTS students (
          id INTEGER PRIMARY KEY, 
          name TEXT, 
          grade TEXT
          )
          SQL
      DB[:conn].execute(sql) 
    end

    def self.drop_table
    sql = <<-SQL
    DROP TABLE IF EXISTS students;
    SQL
    DB[:conn].execute(sql)
  end

  def save
    sql = <<-SQL
    INSERT INTO students (name, grade)
    VALUES (?, ?)
    SQL

    DB[:conn].execute(sql,self.name,self.grade)

    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]

  end  

  def self.create(name:, grade:)
    student = Student.new(name, grade)
    student.save
    student

  end

  def self.new_from_db(row)
    new_student = self.new
    new_student.id = row[0]
    new_student.name = row[1]
    new_student.grade = row[2]
    new_student
  end  

  def self.find_by_name(name)
    sql = <<-SQL 
    SELECT *
    FROM students
    WHERE name = ?
    LIMIT 1
    SQL
    
    DB[:conn].execute(sql,name).map do (row)
      self.new_from_db(row)
    end.first
    
  end

  def self.all
    sql = <<-SQL
    SELECT *
    FROM students
    SQL
    
    DB[:conn].execute(sql).map do |row|
      self.new_from_db(row)
  end 
    
  def self.all_students_in_grade_9
    sql = <<-SQL
    SELECT *
    FROM students
    WHERE student.grade = "9"
    GROUP BY student.name
    SQL

    DB[:conn].execute(sql, self.grade).map do |row|
      self.new_from_db(row)
    end
  end 

  def self.students_below_12th_grade
    sql = <<-SQL
    SELECT *
    FROM students
    WHERE student.grade < "12"
    GROUP BY student.name
    SQL

    DB[:conn].execute(sql, self.grade).map do |row|
      self.new_from_db(row)
    end
  end
end
end



#   # Remember, you can access your database connection anywhere in this class
#   #  with DB[:conn]  
  
 
