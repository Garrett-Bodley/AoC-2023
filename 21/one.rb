#  frozen_string_literal: true

require 'pathname'
require 'pry-nav'
require_relative '../rotate_matrix'

arg = ARGV.shift

case arg
when /input|input.txt/
  FILE_PATH = Pathname.new(File.expand_path('input.txt'))
when /test|test.txt/
  FILE_PATH = Pathname.new(File.expand_path('test.txt'))
else
  raise ArgumentError, "Expects 'input' or 'test' as command line argument"
end

matrix = File.open(FILE_PATH, File::RDONLY).readlines(chomp: true).map { |line| line.split('') }

# Solves Day 21
class Solver
  Coord = Struct.new(*%i[x y steps]) do
    def to_s
      "#{x},#{y}"
    end
  end

  def initialize(matrix, step_count)
    @matrix = matrix
    @step_count = step_count
    @start = find_start
    bfs
  end

  def solve
    bfs
  end

  def bfs
    @visited = {}
    q = Queue.new
    q << @start
    until q.empty?
      cur = q.shift
      next if cur.steps > @step_count
      next if @visited[cur.to_s]

      @visited[cur.to_s] = cur
      neighbors = get_neighbors(cur)
      neighbors.each { |coord| q << coord }
    end

    plots = @visited.values.filter do |coord|
      (@step_count - coord.steps).even?
    end
    plots.length
  end

  def get_neighbors(prev)
    [north(prev), south(prev), east(prev), west(prev)].compact
  end

  def north(prev)
    new_y = prev.y - 1
    return nil if new_y < 0
    return nil unless @matrix[new_y][prev.x].match?(/\.|S/)

    Coord.new(prev.x, new_y, prev.steps + 1)
  end

  def south(prev)
    new_y = prev.y + 1
    return nil if new_y >= @matrix.length
    return nil unless @matrix[new_y][prev.x].match?(/\.|S/)

    Coord.new(prev.x, new_y, prev.steps + 1)
  end

  def east(prev)
    new_x = prev.x + 1
    return nil if new_x >= @matrix[0].length
    return nil unless @matrix[prev.y][new_x].match?(/\.|S/)

    Coord.new(new_x, prev.y, prev.steps + 1)
  end

  def west(prev)
    new_x = prev.x - 1
    return nil if new_x < 0
    return nil unless @matrix[prev.y][new_x].match?(/\.|S/)

    Coord.new(new_x, prev.y, prev.steps + 1)
  end

  def find_start
    @matrix.each_with_index do |row, y|
      row.each_with_index do |char, x|
        return Coord.new(x, y, 0) if char == 'S'
      end
    end
  end

end

s = Solver.new(matrix, 64)
puts s.solve

# expects 3737
