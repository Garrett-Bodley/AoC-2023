# frozen_string_literal: true

require 'pathname'
require 'pry-nav'

arg = ARGV.shift

case arg
when /input|input.txt/
  FILE_PATH = Pathname.new(File.expand_path('input.txt'))
when /test|test.txt/
  FILE_PATH = Pathname.new(File.expand_path('test.txt'))
else
  raise ArgumentError, "Expects 'input' or 'test' as command line argument"
end

lines = File.open(FILE_PATH, File::RDONLY).readlines(chomp: true)

# log_path = FILE_PATH.parent.join("#{FILE_PATH.basename('.*')}_log.txt")
# log_file = File.open(log_path, 'w+')

puzzles = lines.slice_before('').map { |chunk| chunk.reject(&:empty?) }.reject(&:empty?)
               .map { |puzzle| puzzle.map { |line| line.split('') } }


# rotates matrix counter clockwise
def rotate(matrix)
  rotated = []
  (matrix[0].length - 1).downto(0).each do |x|
    row = []
    (0...matrix.length).each do |y|
      row << matrix[y][x]
    end
    rotated << row
  end
  rotated
end

# checks if a matrix is symmetric given an index
def symmetric?(left, matrix) # rubocop:disable Metrics/MethodLength
  l = left
  r = left + 1

  lsize = l + 1
  rsize = matrix[0].length - lsize
  reflection_size = [lsize, rsize].min * 2

  width = 0
  while width < reflection_size
    matrix.each do |row|
      return false if row[l] != row[r]
    end
    l -= 1
    r += 1
    width += 2
  end
  true
end

# finds the left index of the matrix's symmetry or returns -1
def find_symmetry(matrix)
  (0...matrix[0].length - 1).each do |start|
    return start if symmetric?(start, matrix)
  end
  -1
end

checksum = 0

puzzles.each do |puzzle|
  first = find_symmetry(puzzle)

  if first != -1
    checksum += first + 1
    next
  end

  second = find_symmetry(rotate(puzzle))
  checksum += (second + 1) * 100
end

puts checksum

# expects 30535
