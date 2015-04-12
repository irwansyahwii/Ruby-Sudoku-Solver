class SudokuBlock
  attr_accessor :board
  attr_accessor :col_index_range
  attr_accessor :row_index_range

  def initialize(board, col_index_range, row_index_range)
    self.board = board
    self.col_index_range = col_index_range
    self.row_index_range = row_index_range
  end

  def count_of(cell_value)
    col_indexes = self.col_index_range.to_a
    row_indexes = self.row_index_range.to_a

    [0, 1, 2]
    [3, 4, 5]

    size = col_indexes.size
    i = 0
    count = 0

    row_indexes.each do |row_index|
      col_indexes.each do |col_index|
        curr_cell_value = self.board[[row_index, col_index]]
        if curr_cell_value == cell_value
          count += 1
        end
      end      
    end
    count
  end

  def puts_to_empty_cell(seed_cell_value)
    col_indexes = self.col_index_range.to_a
    row_indexes = self.row_index_range.to_a

    row_indexes.each do |row_index|
      col_indexes.each do |col_index|
        curr_cell_value = self.board[[row_index, col_index]]
        if curr_cell_value == "*"
          self.board[[row_index, col_index]] = seed_cell_value
        end
      end      
    end
  end

end

class SudoSolver
  attr_accessor :board
  attr_accessor :index_of_cell_value
  attr_accessor :blocks

  def initialize()
    self.board = Hash.new
    self.index_of_cell_value = Hash.new
    self.blocks = []
  end

  def build_indexes
    row_index = 0
    col_index = 0

    self.index_of_cell_value = Hash.new

    while row_index < 9

      col_index = 0
      while col_index < 9

        s = self.board[[row_index, col_index]]
        if s != "*"
          current_index_value = self.index_of_cell_value[s] 
          if current_index_value.nil?
            current_index_value = []
          end
          current_index_value << [row_index, col_index]

          self.index_of_cell_value[s]  = current_index_value
        end

        
        col_index += 1
      end
      
      row_index += 1
    end

  end

  def read_file(file_name)

    f = File.open(file_name, "r")
    row_index = 0
    col_index = 0
    f.each_line do |line|
      arr = line.split(",")      
      if arr.size == 9
        col_index = 0
        arr.each do |s|
          s.strip!
          self.board[[row_index, col_index]] = s
          # if s != "*"
          #   current_index_value = self.index_of_cell_value[s] 
          #   if current_index_value.nil?
          #     current_index_value = []
          #   end
          #   current_index_value << [row_index, col_index]

          #   self.index_of_cell_value[s]  = current_index_value
          # end
          col_index += 1
        end
        row_index += 1
      end
    end  
    # puts self.board  

    f.close    


    ranges = [ (0..2), (3..5), (6..8) ]

    puts "Creating blocks"
    ranges.each do |row_range|
      ranges.each do |col_range|        
        block = SudokuBlock.new self.board, row_range, col_range
        self.blocks << block
      end
    end

    puts "All block created"

    build_indexes

  end

  def print_current_board
    row_index = 0
    col_index = 0
    row_printed = 0
    while row_index < 9
      curr_line = ""
      col_index = 0

      cell_printed = 0
      
      while col_index < 9
        curr_cell = self.board[[row_index, col_index]]
        if curr_line.size > 0
          curr_line += ","
        end
        if cell_printed == 3
          curr_line += " "
          cell_printed = 0
        end
        curr_line += curr_cell
        cell_printed += 1

        col_index += 1
      end
      if row_printed == 3
        puts ""
        row_printed = 0
      end

      puts curr_line
      row_printed += 1

      row_index+= 1
    end
  end

  def mark(seed_cell, cell_row_index, cell_col_index)

    original_cell_col_index = cell_col_index

    cell_col_index = 0
    while cell_col_index < 9
      curr_cell = self.board[[cell_row_index, cell_col_index]]
      if curr_cell == "*"
        self.board[[cell_row_index, cell_col_index]] = "n#{seed_cell}"
      end
      cell_col_index += 1
    end


    cell_row_index = 0
    cell_col_index = original_cell_col_index
    while cell_row_index < 9
      curr_cell = self.board[[cell_row_index, cell_col_index]]
      if curr_cell == "*"
        self.board[[cell_row_index, cell_col_index]] = "n#{seed_cell}"
      end
      cell_row_index += 1
    end
  end

  def fill_correct_value(seed_cell_value)
    self.blocks.each do |block|
      count = block.count_of "*"

      if count == 1
        count = block.count_of seed_cell_value
        if count == 0          
          block.puts_to_empty_cell seed_cell_value
        end
        
      end
    end
  end

  def clean_marks(curr_cell_value)
    row_index = 0
    col_index = 0
    while row_index < 9

      col_index = 0
      while col_index < 9
        curr_cell = self.board[[row_index, col_index]]
        if curr_cell == "n#{curr_cell_value}"
          self.board[[row_index, col_index]] = "*"
        end
        col_index += 1
      end
      row_index += 1
    end
    
  end

  def try_solve!
    row_index = 0
    col_index = 0

    while row_index < 9
      col_index = 0
      while col_index < 9
        curr_cell = self.board[[row_index, col_index]]
        if curr_cell != "*"
          index_cell = self.index_of_cell_value[curr_cell]
          if !index_cell.nil?            
            index_cell.each do |pos|              
              mark(curr_cell, pos[0], pos[1])
            end
            fill_correct_value curr_cell
            clean_marks curr_cell

            build_indexes
          end                  
        end
        col_index += 1        
      end
      
      row_index += 1
    end    
  end

  def solve!

    count_mark = 0

    try_count = 5

    while try_count > 0
      try_solve!
      try_count -= 1
    end


  end
end


solver = SudoSolver.new
solver.read_file("simple_sudoku.def")
puts "#--- ORIGINAL ---#"
solver.print_current_board
puts "#--ORIGINAL END --#"

solver.solve!
solver.print_current_board
