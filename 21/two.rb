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
class Solver # rubocop:disable Metrics/ClassLength
  Coord = Struct.new(*%i[x y steps]) do
    def to_s
      "#{x},#{y}"
    end
  end

  def initialize(matrix)
    @matrix = matrix
    @width = matrix[0].length
    @start = find_start
    # @edges = valid_edges
    @map = bfs(@start)
  end

  # I gave up and looked online
  # Code explanation: https://github.com/villuna/aoc23/wiki/A-Geometric-solution-to-advent-of-code-2023,-day-21
  def solve # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    # Steps to travel:
    # 26501365

    # It takes 65 steps to get to the edge
    # Everything beyond 65 steps is the corners
    even_corner = @map.values.filter do |coord|
      coord.steps > 65 && coord.steps.even?
    end.count

    odd_corner = @map.values.filter do |coord|
      coord.steps > 65 && coord.steps.odd?
    end.count

    even_full = @map.values.filter do |coord|
      coord.steps.even?
    end.count

    odd_full = @map.values.filter do |coord|
      coord.steps.odd?
    end.count

    blocks_count_to_edge = (26_501_365 - @width / 2) / @width

    n = blocks_count_to_edge

    res = (n + 1)**2 * odd_full + n**2 * even_full - (n + 1) * odd_corner + n * even_corner
    puts res
  end

  # I thought maybe we had to do djikstra or BFS from each edge to each edge and do a hard graph problem
  # That was not the way to solve this specific problem
  def valid_edges # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    res = []

    top_row_idx = 0
    last_row_idx = @matrix.length - 1
    (0...@matrix[0].length).each do |x|
      top_char = @matrix[top_row_idx][x]
      bottom_char = @matrix[last_row_idx][x]

      res << Coord.new(x, top_row_idx, 0) if top_char == '.'
      res << Coord.new(x, last_row_idx, 0) if bottom_char == '.'
    end

    first_col_idx = 0
    last_col_idx = @matrix[0].length - 1
    (0...@matrix.length).each do |y|
      left_char = @matrix[y][first_col_idx]
      right_char = @matrix[y][last_col_idx]

      res << Coord.new(first_col_idx, y, 0) if left_char == '.'
      res << Coord.new(last_col_idx, y, 0) if right_char == '.'
    end
    res.uniq
  end

  # I thought maybe I could count the number of plots and divide by 2 and then use geometry
  # That didn't work
  def log_matrix_plots
    plot_count = @matrix.reduce(0) do |sum, row|
      row_sum = row.reduce(0) do |row_sum, char|
        char == '.' ? row_sum + 1 : row_sum
      end
      sum + row_sum
    end
    puts plot_count
  end

  def bfs(start) # rubocop:disable Metrics/MethodLength
    visited = {}
    q = Queue.new
    q << start
    until q.empty?
      cur = q.shift
      next if visited[cur.to_s]

      visited[cur.to_s] = cur
      neighbors = get_neighbors(cur)
      neighbors.each { |coord| q << coord }
    end

    visited
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

s = Solver.new(matrix)
puts s.solve

# expects 625382480005896
