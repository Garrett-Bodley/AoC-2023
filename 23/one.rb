# frozen_string_literal: true

require 'pathname'
require 'pry-nav'
require 'rb_heap'

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

# Solves Day 23 Part 1
class Solver

  Coord = Struct.new(*%i[x y steps char path]) do
    def to_s
      "#{x},#{y}"
    end
  end

  def initialize(input)
    @matrix = input.map{ _1.split('') }
  end

  def dijkstra(target = Coord.new(@matrix[0].length - 2, @matrix.length - 1))
    start = Coord.new(1, 0, 0)
    start.char = @matrix[0][1]
    start.path = Set.new
    heap = Heap.new { |a, b| a.steps > b.steps }
    heap.add(start)
    visited = {}
    until heap.empty?
      cur = heap.pop

      # return cur.steps if cur.x == target.x && cur.y == target.y

      neighbors = get_neighbors(cur)
      filtered = neighbors.map do |coord|
        if visited[coord.to_s].nil? || coord.steps > visited[coord.to_s].steps
          visited[coord.to_s] = coord
        end
      end.compact

      filtered.each { heap.add(_1) }
    end
    visited[target.to_s].steps
  end

  def get_neighbors(coord)
    case coord.char
    when '^'
      neighbors = [north(coord)].compact
    when 'v'
      neighbors = [south(coord)].compact
    when '>'
      neighbors = [east(coord)].compact
    when '<'
      neighbors = [west(coord)].compact
    when '.'
      neighbors = [north(coord), south(coord), east(coord), west(coord)].compact
    end
    neighbors.reject { coord.path.include?(_1.to_s) }
  end

  def north(coord)
    return nil if coord.y == 0

    new_y = coord.y - 1
    char = @matrix[new_y][coord.x]
    return nil if char == '#'

    Coord.new(coord.x, new_y, coord.steps + 1, char, coord.path.dup.add(coord.to_s))
  end

  def south(coord)
    return nil if coord.y == @matrix.length - 1

    new_y = coord.y + 1
    char = @matrix[new_y][coord.x]
    return nil if char == '#'

    Coord.new(coord.x, new_y, coord.steps + 1, char, coord.path.dup.add(coord.to_s))
  end

  def east(coord)
    return nil if coord.x == @matrix[0].length - 1

    new_x = coord.x + 1
    char = @matrix[coord.y][new_x]
    return nil if char == '#'

    Coord.new(new_x, coord.y, coord.steps + 1, char, coord.path.dup.add(coord.to_s))
  end

  def west(coord)
    return nil if coord.x == 0

    new_x = coord.x - 1
    char = @matrix[coord.y][new_x]
    return nil if char == '#'

    Coord.new(new_x, coord.y, coord.steps + 1, char, coord.path.dup.add(coord.to_s))
  end

end

s = Solver.new(lines)
puts s.dijkstra

# expects 2414
