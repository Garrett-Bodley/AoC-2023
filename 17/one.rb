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
    coords = [Coord.new(0, 0, 'S', 0, nil, 0)]
    until coords.empty?
      cur = coords.shift
      # binding.pry
      if cur.x == @width - 1 && cur.y == @height - 1
        trace(cur)
        return cur.weight
      end

      next_coords = get_next(cur)
      filtered = next_coords.map do |coord|
        coord.weight = calc_weight(coord, cur)
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
      puts coords.length
      # binding.pry
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
    end
  end

  def north(prev)
    return nil if prev.dir == 'S' || (prev.dir == 'N' && prev.dir_count == 3) || prev.y == 0

    dir_count = eval_dir_count('N', prev)
    Coord.new(prev.x, prev.y - 1, 'N', dir_count, prev)
  end

  def south(prev)
    return nil if prev.dir == 'N' || (prev.dir == 'S' && prev.dir_count == 3) || prev.y == @height - 1

    dir_count = eval_dir_count('S', prev)
    Coord.new(prev.x, prev.y + 1, 'S', dir_count, prev)
  end

  def east(prev)
    return nil if prev.dir == 'W' || (prev.dir == 'E' && prev.dir_count == 3) || prev.x == @width - 1

    dir_count = eval_dir_count('E', prev)
    Coord.new(prev.x + 1, prev.y, 'E', dir_count, prev)
  end

  def west(prev)
    return nil if prev.dir == 'E' || (prev.dir == 'W' && prev.dir_count == 3) || prev.x == 0

    dir_count = eval_dir_count('W', prev)
    Coord.new(prev.x - 1, prev.y, 'W', dir_count, prev)
  end

  def eval_dir_count(dir, prev)
    prev.dir == dir ? prev.dir_count + 1 : 1
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
puts pf.find_path

# expects 755
