# frozen_string_literal: true

require 'pathname'
require 'pry-nav'
require '../rotate_matrix'

arg = ARGV.shift

case arg
when /input|input.txt/
  FILE_PATH = Pathname.new(File.expand_path('input.txt'))
when /test|test.txt/
  FILE_PATH = Pathname.new(File.expand_path('test.txt'))
else
  raise ArgumentError, "Expects 'input' or 'test' as command line argument"
end

lines = File.open(FILE_PATH, File::RDONLY).readlines(chomp: true).map { |line| line.split('') }

rotated_path = "#{FILE_PATH.basename('.*')}_rotated_log.txt"
rotated_file = File.open(rotated_path, 'w+')

# Rotates the matrix clockwise
def rotate(matrix)
  rotated = []
  (0...matrix[0].length).each do |x|
    row = []
    (matrix.length - 1).downto(0).each do |y|
      row << matrix[y][x]
    end
    rotated << row
  end
  rotated
end

# problem has changed. We are now tilting EAST aka RIGHT
# It's easier for me to think in rows instead of columns

# rotated = rotate(lines)
rotated = MatrixRotate.clockwise(lines)
rotated.each { |row| rotated_file.puts row.join('') }
rotated_file.flush

# rotated.map! { |row| row.join('') }

def tilt_group(str)
  return str if str.empty?
  count = 0
  (0...str.length).each do |i|
    count += 1 if str[i] == 'O'
  end

  (str.length - 1).downto(0).each do |i|
    if count > 0
      str[i] = 'O'
      count -= 1
    else
      str[i] = '.'
    end
  end
  str
end

# splits the string into substrings separated by '#'.
# Each '#' becomes an empty string element in the subsequent array
def weird_split(str)
  res = []
  sub_str = ''
  str.each_char do |char|
    if char == '#'
      res << sub_str unless sub_str.empty?
      res << ''
      sub_str = ''
      next
    else
      sub_str += char
    end
  end
  res << sub_str unless sub_str.empty?
  res
end

# Joins my weird hacky split format back together
def weird_join(arr)
  arr.map { |str| str.empty? ? '#' : str }.join
end

def tilt_matrix(matrix)
  matrix.map(&:join).map do |row|
    groups = weird_split(row)
    tilted_groups = groups.map { |group| tilt_group(group) }
    tilted_row = weird_join(tilted_groups)
    raise StandardError if row.length != tilted_row.length

    tilted_row
  end.map { |row| row.split('') }
end

def checksum(matrix)
  checksum = 0
  matrix.each do |row|
    row.each_with_index do |char, index|
      checksum += index + 1 if char == 'O'
    end
  end
  checksum
end

def spin_cycle(matrix)
  tmp = matrix
  4.times do
    tmp = tilt_matrix(tmp)
    tmp = MatrixRotate.clockwise(tmp)
  end
  tmp
end

$spin_dict = {}
def multi_spin(matrix, count = 1)
  tmp = matrix
  count.times do |i|
    $spin_dict[tmp] = spin_cycle(tmp)
    tmp = $spin_dict[tmp]
  end
  tmp
end

Cycle = Struct.new(:matrix, :index, :cycle_length)

def find_cycle(matrix)
  visited = {}
  visited[matrix] = 0
  cur = matrix
  (1...Float::INFINITY).each do |i|
    spun = spin_cycle(cur)
    if visited[spun]
      cycle_length = i - visited[spun]
      return Cycle.new(spun, visited[spun], cycle_length)
    else
      visited[spun] = i
      cur = spun
    end
  end
end

cycle = find_cycle(rotated)
lead_in = cycle.index
spin_count = lead_in + (1_000_000_000 - lead_in) % cycle.cycle_length
checksum = checksum(multi_spin(rotated, spin_count))

puts checksum

# expects 102943
