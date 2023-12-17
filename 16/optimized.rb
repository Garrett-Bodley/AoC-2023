# frozen_string_literal: true

require 'pathname'
require 'pry-nav'
require '../rotate_matrix'

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

class Path
  attr_accessor :dict, :matrix

  Entry = Struct.new(*%i[visited coords])

  def initialize(width, height)
    @dict = {}
    build_matrix(width, height)
  end

  def visit(coord)
    matrix[coord.y][coord.x][coord.dir].visited = true
  end

  def visited?(coord)
    @matrix[coord.y][coord.x][coord.dir].visited
  end

  def set_count(coord, count)
    @matrix[coord.y][coord.x][coord.dir].activation_count = count
  end

  def count(coord)
    @matrix[coord.y][coord.x][coord.dir].activation_count
  end

  def add(coord)
    str = hash_string(coord)
    bucket = @dict[str]
    if bucket
      bucket << coord.dir
    else
      @dict[str] = [coord.dir]
    end
  end

  def cycle?(coord)
    str = hash_string(coord)
    bucket = @dict[str]
    return false unless bucket

    bucket.include?(coord.dir)
  end

  def hash_string(coord)
    "#{coord.x},#{coord.y}"
  end

  private

  def build_matrix(width, height)
    dirs = %w[N S E W]
    @matrix = Array.new(height).map do
      Array.new(width).map do
        {}.tap do |hash|
          dirs.each { |dir| hash[dir] = Entry.new(false, 0) }
        end
      end
    end
  end
end

class LightPuzzle
  attr_accessor :matrix, :path, :height, :width

  Coord = Struct.new(:x, :y, :dir, :char) do
    def to_s
      "#{x},#{y}"
    end
  end
  InvalidChar = Class.new(StandardError)
  def initialize(matrix)
    @matrix = matrix
    @height = matrix.length
    @width = matrix[0].length
    @path = Path.new(@width, @height)
  end

  def traverse(coord)
    return @path.count(coord) if @path.visited?(coord)
    binding.pry
    # binding.pry if coord.x == 1 && coord.y == 7
    @path.visit(coord)
    next_coords = next_coords(coord)
    filtered = next_coords.reject { |coord| @path.visited?(coord) }
    visited_nodes = filtered.reduce(1) do |sum, coord|
      sum + traverse(coord)
    end
    pp [coord, count]
    count
  end

  def traverse_from(x, y, dir)
    traverse(Coord.new(x, y, dir))
  end

  def find_best
    top = traverse_top_row
    bottom = traverse_bottom_row
    left = traverse_left_col
    right = traverse_right_col
    [top, bottom, left, right].flatten.max
  end

  def traverse_top_row
    (0...@width).map do |x|
      traverse(x, 0, 'S')
    end
  end

  def traverse_bottom_row
    (0...@width).map do |x|
      traverse(x, @height - 1, 'N')
    end
  end

  def traverse_left_col
    (0...@height).map do |y|
      traverse(0, y, 'E')
    end
  end

  def traverse_right_col
    (0...@height).map do |y|
      traverse(@width - 1, y, 'W')
    end
  end

  def next_coords(coord)
    get_char(coord)
    get_next(coord)
  end

  def get_char(coord)
    coord.char = matrix[coord.y][coord.x]
  end

  def get_next(coord)
    next_coords = []
    case coord.char
    when '.'
      next_coords += stay_course(coord)
    when '/'
      next_coords += slash(coord)
    when '\\'
      next_coords += backslash(coord)
    when '|'
      next_coords += split_vert(coord)
    when '-'
      next_coords += split_horiz(coord)
    end
    next_coords.flatten.compact
  end

  def split_vert(coord)
    raise InvalidChar unless coord.char.match?('|')
    return stay_course(coord) unless coord.dir.match?(/E|W/)

    [north(coord), south(coord)]
  end

  def split_horiz(coord)
    raise InvalidChar unless coord.char.match?('-')
    return stay_course(coord) unless coord.dir.match?(/N|S/)

    [east(coord), west(coord)]
  end

  def slash(coord)
    raise InvalidChar unless coord.char.match?('/')

    case coord.dir
    when 'N'
      east(coord)
    when 'S'
      west(coord)
    when 'E'
      north(coord)
    when 'W'
      south(coord)
    end
  end

  def backslash(coord)
    raise InvalidChar unless coord.char.match?(/\\/)

    case coord.dir
    when 'N'
      west(coord)
    when 'S'
      east(coord)
    when 'E'
      south(coord)
    when 'W'
      north(coord)
    end
  end

  def stay_course(coord)
    case coord.dir
    when 'N'
      north(coord)
    when 'S'
      south(coord)
    when 'E'
      east(coord)
    when 'W'
      west(coord)
    end
  end

  def north(coord)
    return [nil] if coord.y.zero?

    [Coord.new(coord.x, coord.y - 1, 'N')]
  end

  def south(coord)
    return [nil] if coord.y == @height - 1

    [Coord.new(coord.x, coord.y + 1, 'S')]
  end

  def east(coord)
    return [nil] if coord.x == @width - 1

    [Coord.new(coord.x + 1, coord.y, 'E')]
  end

  def west(coord)
    return [nil] if coord.x.zero?

    [Coord.new(coord.x - 1, coord.y, 'W')]
  end
end

lp = LightPuzzle.new(matrix)
res = lp.traverse_from(0, 0, 'E')
# binding.pry
# puts lp.find_best

# expects 7041
