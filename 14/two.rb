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

$rotate_map = {}
# rotates the matrix clockwise
def rotate(matrix)
  return $rotate_map[matrix] if $rotate_map[matrix]

  rotated = []
  (0...matrix[0].length).each do |x|
    row = []
    (matrix.length - 1).downto(0).each do |y|
      row << matrix[y][x]
    end
    rotated << row
  end
  $rotate_map[matrix] = rotated
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

$tilt_map = {}
def tilt_matrix(matrix)
  return $tilt_map[matrix] if $tilt_map[matrix]

  tilted = matrix.map do |row|
    weird_join(weird_split(row.join('')).map { |group| tilt(group) }).split('')
  end
  $tilt_map[matrix] = tilted
  tilted
end

$cycle_hash = {}
def spin_cycle(matrix)
  return $cycle_hash[matrix] if $cycle_hash[matrix]
  i = 0
  while i < 4
    tmp = tilt_matrix(matrix)
    tmp = rotate(tmp)
    i += 1
  end

  $cycle_hash[matrix] = tmp
  tmp
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

def run_cycles(matrix, times)
  dict = {}
  cycle_log = []
  times.times do
    # return cycle_log if dict[matrix]

    tmp = spin_cycle(matrix)
    dict[matrix] = tmp
    cycle_log << checksum(tmp)
    matrix = tmp
  end
  matrix
end

def log_spin(matrix, file)
  tmp = matrix
  3.times { tmp = rotate(tmp) }
  tmp.each { |row| file.puts row.join('') }
  file.flush
end


# spin_path = "#{FILE_PATH.basename('.*')}_spin_log.txt"
# spin_file = File.open(spin_path, 'w+')


tilted = tilt_matrix(rotated)
# binding.pry
log = run_cycles(rotated, 1_000)
checksum = 0

# log.uniq.each do |num|
#   spin_file.puts "num: #{num}"
#   lengths = log.slice_before(num).map(&:length)
#   lengths.uniq.each do |entry|
#     spin_file.puts "  cycle_length: #{entry}, times: #{lengths.count(entry)}"
#   end
# end

# log.each_slice(20).each {|slice| spin_file.puts slice.join(' ')}
# spin_file.flush
# binding.pry

spun.each do |row|
  row.each_with_index do |char, index|
    checksum += index + 1 if char == 'O'
  end
end

# spin_file.puts checksum
puts checksum

log_spin(spun, spin_file)
# expects 105208
