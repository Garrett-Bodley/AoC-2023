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
  attr_accessor :dict

  def initialize
    @dict = {}
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
end

class LightPuzzle
  attr_accessor :matrix, :path, :height, :width

  Coord = Struct.new(:x, :y, :dir, :char)
  InvalidChar = Class.new(StandardError)
  InvalidDir = Class.new(StandardError)
  def initialize(matrix)
    @matrix = matrix
    @height = matrix.length
    @width = matrix[0].length
  end

  def traverse(x, y, dir)
    coords = [Coord.new(x, y, dir)]
    @path = Path.new
    until coords.empty?
      cur = coords.shift
      @path.add(cur)
      next_coords = next_coords(cur).compact
      filtered = next_coords.reject { |coord| path.cycle?(coord) }
      coords += filtered
    end
    puts @path.dict.length
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

    [north(coord), south(coord)].compact
  end

  def split_horiz(coord)
    raise InvalidChar unless coord.char.match?('-')
    return stay_course(coord) unless coord.dir.match?(/N|S/)

    [east(coord), west(coord)].compact
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
lp.traverse(0, 0, 'E')

# expects 6740
