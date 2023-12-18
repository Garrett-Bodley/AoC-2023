# frozen_string_literal: true

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

lines = File.open(FILE_PATH, File::RDONLY).readlines(chomp: true).map do |line|
  dir, count, color = line.split(' ')
  [dir, count.to_i, color]
end

class Solver
  attr_accessor :matrix

  NUM_TO_DIR = {
    '0' => 'R',
    '1' => 'D',
    '2' => 'L',
    '3' => 'U'
  }

  Coord = Struct.new(*%i[x y]) do
    def to_s
      "#{x},#{y}"
    end
  end

  def initialize(lines)
    @instructions = lines.map { |line| decode_instruction(line[2]) }
    @coord = Coord.new(0, 0)
    @matrix = [['#']]
  end

  def solve
    @instructions.each_with_index do |(dir, count), i|
      puts i
      # binding.pry
      case dir
      when 'U'
        move_up(count)
      when 'D'
        move_down(count)
      when 'L'
        move_left(count)
      when 'R'
        move_right(count)
      end
    end
    MatrixRotate.log(@matrix)
    puts
    flood_fill(106, 4)
    MatrixRotate.log(@matrix)
    @matrix.reduce(0) do |sum, row|
      sum + row.filter { |char| char == '#' }.length
    end
  end

  def decode_instruction(color)
    dir = color.slice(7, 1)
    count = color.slice(2, 5).to_i(16)
    [NUM_TO_DIR[dir], count]
  end

  def move_up(count)
    if @coord.y - count < 0
      grow_by = count - @coord.y
      grow_matrix_up(grow_by)
    end
    count.times do
      @coord.y -= 1
      @matrix[@coord.y][@coord.x] = '#'
    end
  end

  def move_down(count)
    if @coord.y + count > @matrix.length - 1
      grow_by = @coord.y + count - (@matrix.length - 1)
      grow_matrix_down(grow_by)
    end
    count.times do
      @coord.y += 1
      @matrix[@coord.y][@coord.x] = '#'
    end
  end

  def move_left(count)
    if @coord.x - count < 0
      grow_by = count - @coord.x
      grow_matrix_left(grow_by)
    end

    count.times do
      @coord.x -= 1
      @matrix[@coord.y][@coord.x] = '#'
    end
  end

  def move_right(count)
    if @coord.x + count > @matrix[0].length - 1
      grow_by = @coord.x + count - (matrix[0].length - 1)
      grow_matrix_right(grow_by)
    end
    count.times do
      @coord.x += 1
      @matrix[@coord.y][@coord.x] = '#'
    end
  end

  def grow_matrix(dir, count)
    case dir
    when 'U'
      grow_matrix_up(count)
    when 'D'
      grow_matrix_down(count)
    when 'L'
      grow_matrix_left(count)
    when 'R'
      grow_matrix_right(count)
    end
  end

  def grow_matrix_up(count)
    to_prepend = Array.new(count).map { Array.new(@matrix[0].length, '.') }
    @matrix.unshift(*to_prepend)
    @coord.y += count
  end

  def grow_matrix_down(count)
    to_append = Array.new(count).map { Array.new(@matrix[0].length, '.') }
    @matrix.push(*to_append)
  end

  def grow_matrix_left(count)
    to_prepend = ['.'] * count
    @matrix.map! { |row| row.unshift(*to_prepend) }
    @coord.x += count
  end

  def grow_matrix_right(count)
    to_append = ['.'] * count
    @matrix.each { |row| row.concat(to_append) }
  rescue SystemStackError
    binding.pry
  end

  def flood_fill(x, y)
    @filled = {}
    q = [Coord.new(x, y)]
    until q.empty?
      cur = q.shift
      next if @filled[cur.to_s]

      @matrix[cur.y][cur.x] = '#'
      @filled[cur.to_s] = true
      neighbors = get_flood_neighbors(cur)
      q += neighbors
    end
  end

  def get_flood_neighbors(coord)
    neighbors = []

    neighbors << Coord.new(coord.x - 1, coord.y) unless coord.x == 0
    neighbors << Coord.new(coord.x + 1, coord.y) unless coord.x == @matrix[0].length - 1
    neighbors << Coord.new(coord.x, coord.y - 1) unless coord.y == 0
    neighbors << Coord.new(coord.x, coord.y + 1) unless coord.y == @matrix.length - 1

    neighbors.reject { |neighbor| @matrix[neighbor.y][neighbor.x] == '#' }
  end

  def fill_matrix
    @matrix.each_with_index do |row, _i|
      fill_row(row)
    end
  end

  def fill_row(row)
    crossings = 0
    i = 0
    while i < row.length
      if row[i] == '#'
        i += 1 while row[i + 1] == '#'
        crossings += 1
      elsif crossings.odd?
        row[i] = '#'
      end
      i += 1
    end
  end

end

s = Solver.new(lines)
puts s.solve
