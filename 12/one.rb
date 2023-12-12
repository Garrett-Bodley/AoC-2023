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

data = lines.map do |line|
  springs, nums = line.split(' ')
  [springs.split(''), nums.split(',').map(&:to_i)]
end

# binding.pry
# what the hell is this problem asking?

# given a pattern of ?###???????? 3,2,1
# how do I figure out which chars satisfy the condition
# 3, 2, 1

# this seems like a brute force algorithm?
# how to do fast??

# given first num
# is there a wildcard spot large enough?
# is there enough space in wildcard chunk

# so i'm making permutations of the wild card spots?
# it feels like I need to know where the springs are

# can I reduce the number of test cases to solve

attr = %i[start length line]

Wildcard = Struct.new(*attr)

# def valid?(line, arg_pattern)
#   pattern = [*arg_pattern]

#   i = 0
#   while i < line.length
#     return true if pattern.empty?

#     i += 1 while line[i] != '#' && i < line.length
#     return false unless i < line.length

#     count = 0
#     group = pattern.shift

#     while line[i] == '#' && i < line.length
#       count += 1
#       i += 1
#     end
#     return false if count != group

#     i += 1
#   end
#   pattern.empty? ? true : false
# end

def valid?(line, pattern)
  groups = line.join('').enum_for(:scan, /#+/).map { Regexp.last_match }
  return false if groups.length != pattern.length

  pattern.each_with_index do |group_size, i|
    group = groups[i]
    return false if group[0].length != group_size
  end
  return true
end


# what am I doing???
# I have no idea what I'm doing
def permutations(line, pattern)
  wildcards = line.join('').enum_for(:scan, /\?+/).map { Regexp.last_match }
                  .map { |el| Wildcard.new(el.begin(0), el[0].length, line) }

end

def find_wildcards(line)
  wildcards = line.join('').enum_for(:scan, /\?+/).map { Regexp.last_match }
                  .map { |el| Wildcard.new(el.begin(0), el[0].length, line) }
end

def brute_force(line, i)
  return [line.dup] unless i < line.length

  combinations = []

  if line[i] == '?'

    line[i] = '.'
    combinations += brute_force(line.dup, i + 1)

    line[i] = '#'
    combinations += brute_force(line.dup, i + 1)

  else
    combinations += brute_force(line, i + 1)
  end
  combinations
end

# line, pattern = data.last
# options = brute_force(line, 0)

# valid_options = %w[
#   .###.##.#...
#   .###.##..#..
#   .###.##...#.
#   .###.##....#
#   .###..##.#..
#   .###..##..#.
#   .###..##...#
#   .###...##.#.
#   .###...##..#
#   .###....##.#
# ]
# wrong = [
#   ['.', '#', '#', '#', '.', '.', '#', '#', '.', '#', '.', '#'],
#   ['.', '#', '#', '#', '.', '#', '#', '.', '.', '#', '.', '#'],
#   ['.', '#', '#', '#', '.', '#', '#', '.', '#', '.', '.', '#'],
#   ['.', '#', '#', '#', '.', '#', '#', '.', '#', '.', '#', '.'],
#   ['.', '#', '#', '#', '.', '#', '#', '.', '#', '.', '#', '#']
# ]

# wrong.map! { |line| line.join('') }

# valid = options.filter do |option|
#   valid?(option, pattern)
# end
# binding.pry

res = data.reduce(0) do |sum, (line, pattern)|
  options = brute_force(line, 0)
  valid = options.filter do |option|
    valid?(option, pattern)
  end
  puts valid.length
  sum + valid.length
end

puts res

# data.each do |line, pattern|
#   puts valid?(line, pattern)
# end
