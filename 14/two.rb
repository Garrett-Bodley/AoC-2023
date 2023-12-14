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

lines = File.open(FILE_PATH, File::RDONLY).readlines(chomp: true).map { |line| line.split('') }

rotated_path = "#{FILE_PATH.basename('.*')}_rotated_log.txt"
rotated_file = File.open(rotated_path, 'w+')

# rotates the matrix clockwise
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
rotated = rotate(lines)
rotated.each { |row| rotated_file.puts row.join('') }
rotated_file.flush

def tilt(str) # rubocop:disable Metrics/MethodLength
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

def weird_split(str) # rubocop:disable Metrics/MethodLength
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

def weird_join(arr)
  arr.map { |str| str.empty? ? '#' : str }.join
end

def tilt_matrix(matrix)
  matrix.map do |row|
    weird_join(weird_split(row.join('')).map { |group| tilt(group) }).split('')
  end
end

def spin_cycle(matrix, times)
  times.times do
    4.times do
      matrix = tilt_matrix(matrix)
      matrix = rotate(matrix)
    end
  end
  matrix
end

def log_spin(matrix, file)
  tmp = matrix
  3.times { tmp = rotate(tmp) }
  tmp.each { |row| file.puts row.join('') }
  file.flush
end


spin_path = "#{FILE_PATH.basename('.*')}_spin_log.txt"
spin_file = File.open(spin_path, 'w+')


tilted = tilt_matrix(rotated)
binding.pry
spun = spin_cycle(rotated, 1_000_000_000)
log_spin(spun, spin_file)
binding.pry
checksum = 0



spun.each do |row|
  row.each_with_index do |char, index|
    checksum += index + 1 if char == 'O'
  end
end

puts checksum

# expects 105208
