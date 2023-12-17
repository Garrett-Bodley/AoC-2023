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
    @dp = Array.new(height).map { Array.new(width, Float::INFINITY) }
    @visited = {}
  end

  def find_path
    coords = [Coord.new(0, 0, 'S', 0, nil, 0)]
    until coords.empty?
      cur = coords.shift
      next if visited[cur.to_s]

      visited[cur.to_s] = true
      # binding.pry
      # if cur.x == @width - 1 && cur.y == @height - 1
      #   trace(cur)
      #   return cur.weight
      # end

      # puts "#{cur.to_s} #{cur.weight}"
      next_coords = get_next(cur)
      filtered = next_coords.reject { |coord| visited[coord.to_s] }
      filtered.each do |coord|
        set_weight(coord, cur)
      end
      # binding.pry
      coords += filtered
      coords.sort! { |a, b| a.weight <=> b.weight }
    end
    puts @dp[@height - 1][@width - 1]
  end

  def get_next(coord)
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

  def eval_dir_count(dir, coord)
    coord.dir == dir ? coord.dir_count + 1 : 1
  end

  def set_weight(coord, prev)
    dp_weight = @dp[coord.y][coord.x]
    calc_weight = @matrix[coord.y][coord.x] + prev.weight
    @dp[coord.y][coord.x] = calc_weight if calc_weight < dp_weight

    coord.weight = @dp[coord.y][coord.x]
  end

  def trace(coord)
    while coord
      puts coord.to_s + " #{coord.weight}"
      coord = coord.prev
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
