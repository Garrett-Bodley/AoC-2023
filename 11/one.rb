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

# padded = lines.map { |line| ['.'] + line + ['.'] }

# padded << Array.new(padded[0].length, '.')
# padded.unshift Array.new(padded[0].length, '.')

# expand_file.seek(0)
# padded.each { |line| expand_file.puts line.join('') }

Coord = Struct.new(:x, :y, :distance)

galaxies = []

lines.each_with_index do |line, y|
  line.each_with_index do |char, x|
    galaxies << Coord.new(x, y, 0) if char == '#'
  end
end
expand_file.flush
# galaxies.each { |coord| puts "#{coord.x}, #{coord.y}" }

pairs = []

(0...galaxies.length).each do |i|
  (i + 1...galaxies.length).each do |j|
    pairs << [galaxies[i], galaxies[j]]
  end
end

$matrix = lines

def get_neighbors(node, visited)
  neighbors = []
  (-1..1).each do |offset|
    x = node.x + offset
    y = node.y
    next if x == node.x && y == node.y
    next if x < 0 || x >= $matrix[0].length
    next if y < 0 || y >= $matrix.length
    next unless visited["#{x},#{y}"].nil?

    neighbors << Coord.new(x, y, node.distance + 1)
  end

  (-1..1).each do |offset| # rubocop:disable Style/CombinableLoops
    x = node.x
    y = node.y + offset
    next if x == node.x && y == node.y
    next if x < 0 || x >= $matrix[0].length
    next if y < 0 || y >= $matrix.length
    next unless visited["#{x},#{y}"].nil?

    neighbors << Coord.new(x, y, node.distance + 1)
  end

  neighbors
end

def shortest_path(pair) # not needed! It's just a straight line path!
  a, b = pair
  visited = {}
  q = [a]

  until q.empty?
    cur = q.shift
    neighbors = get_neighbors(cur, visited)

    if neighbors.any? { |coord| coord.x == b.x && coord.y == b.y }
      match = neighbors.find { |coord| coord.x == b.x && coord.y == b.y }
      return match.distance
    end

    neighbors.each do |neighbor|
      visited["#{neighbor.x},#{neighbor.y}"] = true
      q << neighbor
    end
  end
  -1
end

res = pairs.reduce(0) do |sum, pair|
  pair.sort! { |a, b| a.x <=> b.x }
  a, b = pair
  distance = b.x - a.x
  pair.sort! { |a, b| a.y <=> b.y }
  a, b = pair
  distance += b.y - a.y
  sum + distance
end
puts res

# 374 too low! (lol that's the test input answer)
# expects 9734203

# rubocop:enable Style/GlobalVars
