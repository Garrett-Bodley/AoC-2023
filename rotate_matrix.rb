# Utility module for rotating matrices
module MatrixRotate
  def self.rotate(matrix, dir, times = 1)
    case dir
    when '<'
      counter_clockwise(matrix, times)
    when '>'
      clockwise(matrix, times)
    else
      raise ArgumentError, "Matrix::rotate expects '<' or '>' as a second, direction argument"
    end
  end

  def self.clockwise(matrix, times = 1) # rubocop:disable Metrics/MethodLength
    times.times do
      res = []
      (0...matrix[0].length).each do |x|
        row = []
        (matrix.length - 1).downto(0).each do |y|
          row << matrix[y][x]
        end
        res << row
      end
      matrix = res
    end
    matrix
  end

  def self.counter_clockwise(matrix, times = 1) # rubocop:disable Metrics/MethodLength
    times.times do
      res = []
      (matrix[0].length - 1).downto(0).each do |x|
        row = []
        (0...matrix.length).each do |y|
          row << matrix[y][x]
        end
        res << row
      end
      matrix = res
    end
    matrix
  end

  def self.log(matrix)
    matrix.each { |row| puts row.join(' ') }
  end

  def self.rotate_and_log(matrix, dir, times = 1)
    rotated = rotate(matrix, dir, times)
    log(rotated)
    rotated
  end
end
