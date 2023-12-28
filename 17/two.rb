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
    q = Heap.new { |a, b| a.weight < b.weight }
    q.add(Coord.new(0, 0, '*', 0, nil, 0))
    until q.empty?
      cur = q.pop
      # binding.pry
      if cur.x == @width - 1 && cur.y == @height - 1
        trace(cur)
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
      filtered.each { q.add(_1) }
      puts q.size
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
      new_weight = prev.weight + matrix[new_y][prev.x]
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

  # didn't end up using this at all
  def priority_insert(coords, to_insert)
    # linear search for node insertion
    # could definitely be sped up by using binary search but i am lazy
    return [to_insert] if coords.empty?

    coords.each_with_index do |coord, i|
      return coords.insert(i, to_insert) if to_insert.weight <= coord.weight
    end
    coords << to_insert
  end
end

pf = PathFind.new(matrix)
puts pf.find_path
