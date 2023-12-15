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

def pounds_before(line, idx)
  count = 0
  idx -= 1
  while idx > 0 && line[idx] == '#'
    count += 1
    idx -= 1
  end
  count
end

def pounds_after(line, idx)
  count = 0
  idx += 1
  while idx < line.length && line[idx] == '#'
    count += 1
    idx += 1
  end
  count
end

def surrounding_pounds(line, idx)
  pounds_after(line, idx) + pounds_before(line, idx)
end

def placeable_after(line, idx)
  count = 0
  idx += 1
  while idx < line.length && line[idx].match?(/#|\?/)
    count += 1 if line[idx] == '?'
    idx += 1
  end
  count
end

def can_place?(line, pattern, line_idx, pattern_idx)
  return false unless line[line_idx] == '?'

  group_size = pattern[pattern_idx]
  surrounding_pounds = surrounding_pounds(line, line_idx)
  return false if surrounding_pounds + 1 > group_size

  placeable_after = placeable_after(line, line_idx)
  surrounding_pounds + placeable_after + 1 >= group_size
end

def place(line, pattern, line_idx, pattern_idx)
  group_size = pattern[pattern_idx]
  cur_size = surrounding_pounds(line, line_idx) + 1

  new_line = line.dup
  new_line[line_idx] = '#'
  cur = line_idx + pounds_after(line, line_idx) + 1

  while cur_size < group_size
    new_line[cur] = '#'
    cur_size += 1
    cur += 1
  end

  [new_line, cur]
end

def solve(dict, line, pattern, line_idx, pattern_idx)
  return 0 if line.any?('?') && pattern_idx == pattern.length
  return 0 if line_idx == line.length && pattern_idx != pattern.length
  return 1 if line.none?('?') && pattern_idx == pattern.length
  binding.pry if line_idx > line.length || pattern_idx > pattern.length

  # return dict["#{i},#{j}"] if dict["#{i},#{j}"]
  unless can_place?(line, pattern, line_idx, pattern_idx)
    line[line_idx] = '.' if line[line_idx] == '?'
    return solve(dict, line, pattern, line_idx + 1, pattern_idx)
  end

  placed, placed_idx = place(line, pattern, line_idx, pattern_idx)
  unplaced = line.dup
  unplaced[line_idx] = '.'
  placed_combos = solve(dict, placed, pattern, placed_idx, pattern_idx + 1)
  unplaced_combos = solve(dict, unplaced, pattern, line_idx + 1, pattern_idx)
  placed_combos + unplaced_combos
end

# line = data.first.first
# pattern = data.first.last
# test_line = %w[# # . . # . # # ? ? ? ?]
# pattern = [4]
# new_line, new_idx = place(test_line, pattern, 8, 0)
# binding.pry
# can_place?(line, pattern, 0, 0)

data.reduce(0) do |sum, (line, pattern)|
  ncombos = solve({}, line, pattern, 0, 0)
  binding.pry
  sum + ncombos
end

# expects 7843
