# rubocop:disable Style/GlobalVars
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

$empty_rows = []

lines.each_with_index do |line, index|
  $empty_rows << index unless line.any? { |char| char == '#' }
end

$empty_cols = []

(0...lines[0].length).each do |x|
  empty = true
  (0...lines.length).each do |y|
    if lines[y][x] == '#'
      empty = false
      break
    end
  end
  $empty_cols << x if empty
end

Coord = Struct.new(:x, :y)

galaxies = []

lines.each_with_index do |line, y|
  line.each_with_index do |char, x|
    galaxies << Coord.new(x, y) if char == '#'
  end
end

pairs = []

(0...galaxies.length).each do |i|
  (i + 1...galaxies.length).each do |j|
    pairs << [galaxies[i], galaxies[j]]
  end
end

$matrix = lines

FACTOR = 1_000_000

def compute_distance(pair)
  pair.sort! { |a, b| a.x <=> b.x }
  a, b = pair
  distance = 0

  (a.x + 1..b.x).each do |x|
    distance += $empty_cols.include?(x) ? FACTOR : 1
  end

  pair.sort! { |a, b| a.y <=> b.y }
  a, b = pair

  (a.y + 1..b.y).each do |y|
    distance += $empty_rows.include?(y) ? FACTOR : 1
  end
  distance
end

res = pairs.reduce(0) do |sum, pair|
  sum + compute_distance(pair)
end
puts res

# expects 568914596391

# rubocop:enable Style/GlobalVars
