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

lines = File.open(FILE_PATH, File::RDONLY).readlines(chomp: true).map { |l| l.split('') }
# binding.pry
empty_rows = []

lines.each_with_index do |line, index|
  empty_rows << index unless line.any? { |char| char == '#' }
end

empty_cols = []

(0...lines[0].length).each do |x|
  empty = true
  (0...lines.length).each do |y|
    if lines[y][x] == '#'
      empty = false
      break
    end
  end
  empty_cols << x if empty
end

# binding.pry

expand_path = FILE_PATH.parent.join("exp_#{FILE_PATH.basename('.*')}.txt")
expand_file = File.open(expand_path, 'w+')

offset = 0
empty_rows.each do |idx|
  lines.insert(idx + offset, Array.new(lines[0].length, '.'))
  offset += 1
end

offset = 0
empty_cols.each do |idx|
  lines.each do |line|
    line.insert(idx + offset, '.')
  end
  offset += 1
end

lines.each { |line| expand_file.puts line.join('') }

# binding.pry
