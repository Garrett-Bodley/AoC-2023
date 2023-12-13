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

# attr = %i[start length line]

# Wildcard = Struct.new(*attr)

def valid?(line, pattern)
  groups = line.join('').enum_for(:scan, /#+/).map { Regexp.last_match }
  return false if groups.length != pattern.length

  pattern.each_with_index do |group_size, i|
    group = groups[i]
    return false if group[0].length != group_size
  end
  true
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

res = data.reduce(0) do |sum, (line, pattern)|
  options = brute_force(line, 0)
  valid = options.filter do |option|
    valid?(option, pattern)
  end
  puts valid.length
  sum + valid.length
end

puts res

# expects 7843
