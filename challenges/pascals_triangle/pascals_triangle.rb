class Triangle

  def initialize(row_number)
    @row_number = row_number
  end

  def rows
    (@row_number - 1).times.with_object([[1]]) do |i, obj|
      last_row = create_row(obj[i])  
      obj << last_row
    end
  end
end

private 

def create_row(row)
  row.each_with_object([]).with_index do |(value, obj), index|
    if index == 0
      obj << 1
      row.size > 1 ? obj << value + row[index + 1] : obj << 1
    elsif index == row.size - 1
      obj << 1
    else
      obj << value + row[index + 1]
    end
  end
end