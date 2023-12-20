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

matrix = File.open(FILE_PATH, File::RDONLY).readlines(chomp: true).map{ |line| line.split('').map(&:to_i) }

class PathFind
  InvalidDir = Class.new(StandardError)
  Coord = Struct.new(*%i[x y dir dir_count prev weight]) do
    def to_s
      "#{x},#{y},#{dir},#{dir_count}"
    end
  end
  attr_accessor :visited, :matrix, :height, :width, :dp

  def initialize(matrix)
    @matrix = matrix
    @height = matrix.length
    @width = matrix[0].length
    @memo = {}
  end

  def find_path
    coords = [Coord.new(0, 0, '*', 0, nil, 0)]
    until coords.empty?
      cur = coords.shift
      # binding.pry
      if cur.x == @width - 1 && cur.y == @height - 1
        trace(cur)
        binding.pry
        return cur.weight
      end

      next_coords = get_next(cur)
      filtered = next_coords.map do |coord|
        if @memo[coord.to_s].nil? || coord.weight < @memo[coord.to_s].weight
          @memo[coord.to_s] = coord
        else # rubocop:disable Style/EmptyElse
          nil
        end
      end.compact
      # filtered.each do |coord|
      #   set_weight(coord, cur)
      # end
      # binding.pry
      # filtered.each do |to_insert|
      #   priority_insert(coords, to_insert)
      # end
      coords += filtered
      coords.sort! { |a, b| a.weight <=> b.weight }
      # binding.pry
      puts coords.length
    end
  end

  def get_next(coord) # rubocop:disable Metrics/AbcSize
    case coord.dir
    when 'N'
      [north(coord), east(coord), west(coord)].compact
    when 'S'
      [south(coord), east(coord), west(coord)].compact
    when 'E'
      [east(coord), north(coord), south(coord)].compact
    when 'W'
      [west(coord), north(coord), south(coord)].compact
    when '*'
      [north(coord), south(coord), east(coord), west(coord)].compact
    end
  end

  # Once an ultra crucible starts moving in a direction, it needs to move a minimum of four blocks in that direction before it can turn (or even before it can stop at the end). However, it will eventually start to get wobbly: an ultra crucible can move a maximum of ten consecutive blocks without turning.

  # Todo:
  #  I have to account for the weight of all the passed coordinates when moving 4 at once in the beginning :'(
  def north(prev)
    return nil if prev.y.zero?
    return nil if prev.dir == 'S'
    return nil if prev.dir == 'N' && prev.dir_count == 10

    if prev.dir != 'N'
      new_y = prev.y - 4
      return nil if new_y < 0 # rubocop:disable Style/NumericPredicate

      new_weight = prev.weight
      (1...5).each do |offset|
        new_weight += matrix[prev.y - offset][prev.x]
      end
    else
      new_y = prev.y - 1
      new_weight = prev.weight + matrix[new_y][prev.x]
    end

    dir_count = eval_dir_count('N', prev)
    Coord.new(prev.x, new_y, 'N', dir_count, prev, new_weight)
  end

  def south(prev)
    return nil if prev.dir == 'N'
    return nil if prev.dir == 'S' && prev.dir_count == 10
    return nil if prev.y == @height - 1

    if prev.dir != 'S'
      new_y = prev.y + 4
      return nil if new_y > @height - 1

      new_weight = prev.weight
      (1...5).each do |offset|
        new_weight += matrix[prev.y + offset][prev.x]
      end
    else
      new_y = prev.y + 1
      new_weight = matrix[new_y][prev.x]
    end

    dir_count = eval_dir_count('S', prev)
    Coord.new(prev.x, new_y, 'S', dir_count, prev, new_weight)
  end

  def east(prev)
    return nil if prev.dir == 'W'
    return nil if prev.dir == 'E' && prev.dir_count == 10
    return nil if prev.x == @width - 1

    if prev.dir != 'E'
      new_x = prev.x + 4
      return nil if new_x > @width - 1

      new_weight = prev.weight
      (1...5).each do |offset|
        new_weight += matrix[prev.y][prev.x + offset]
      end
    else
      new_x = prev.x + 1
      new_weight = prev.weight + matrix[prev.y][new_x]
    end

    dir_count = eval_dir_count('E', prev)
    Coord.new(new_x, prev.y, 'E', dir_count, prev, new_weight)
  end

  def west(prev)
    return nil if prev.dir == 'E'
    return nil if prev.x.zero?
    return nil if prev.dir == 'W' && prev.dir_count == 3

    if prev.dir != 'W'
      new_x = prev.x - 4
      return nil if new_x < 0

      new_weight = prev.weight
      (1...5).each do |offset|
        new_weight += matrix[prev.y][prev.x - offset]
      end
    else
      new_x = prev.x - 1
      new_weight = prev.weight + matrix[prev.y][new_x]
    end

    dir_count = eval_dir_count('W', prev)
    Coord.new(new_x, prev.y, 'W', dir_count, prev, new_weight)
  end

  def eval_dir_count(dir, prev)
    prev.dir == dir ? prev.dir_count + 1 : 4
  end

  def calc_weight(coord, prev)
    @matrix[coord.y][coord.x] + prev.weight
  end

  def trace(coord)
    while coord
      puts coord.to_s + " #{coord.weight}"
      coord = coord.prev
    end
  end

  def priority_insert(coords, to_insert)
    # linear search for node insertion
    # could definitely be sped up by using binary search but i am lazy
    coords.each_with_index do |coord, i|
      if to_insert.weight <= coord.weight
        coords.insert(i, to_insert)
        break
      end
    end
  end

end

pf = PathFind.new(matrix)
binding.pry
puts pf.find_path

# coordinates
# keep track of weight
# I'm not looking for shortest path necessarily?
# But rather path with the lowest cost
# Do I calculate all paths?
# What if I do an iterative depth first traversal
#   sort the stack each iteration to select for the lowest cost path
#   that could work? but also seems expensive

# Each Node must keep track of
#   its current weight
#   current direction
#   direction_count

# DIJKSTRA
#
# 1. Label each node with infinity
# 2. All nodes are unexplored
# 3. For each node accessible from current node
#   a. Calculate distance to that node from current node
#   b. If calculated distance is less than memoized distance, update distance to smaller value
# 4. Move to the node with the lowest distance
