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

# Checks if a matrix has an off-by-one symmetry
def smudge_symmetric?(left, matrix) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
  l = left
  r = left + 1

  lsize = l + 1
  rsize = matrix[0].length - lsize
  reflection_size = [lsize, rsize].min * 2
  diff_count = 0
  width = 0
  while width < reflection_size
    matrix.each do |row|
      if row[l] != row[r]
        return false if diff_count != 0

        diff_count += 1
      end
    end
    l -= 1
    r += 1
    width += 2
  end
  diff_count == 1
end

# Finds the left index of the matrix's symmetry or returns -1
def find_symmetry(matrix)
  (0...matrix[0].length - 1).each do |start|
    return start if smudge_symmetric?(start, matrix)
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
  binding.pry if first == -1 && second == -1
end

puts checksum

# expects 30844
