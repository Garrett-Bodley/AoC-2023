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

# Solves Day 18 Challenge
class Solver
  attr_accessor :matrix

  NUM_TO_DIR = {
    '0' => 'R',
    '1' => 'D',
    '2' => 'L',
    '3' => 'U'
  }.freeze

  Coord = Struct.new(*%i[x y next prev]) do
    def to_s
      "#{x},#{y}"
    end
  end

  def initialize(lines)
    @lines = lines.map { |line| line.slice(0, 2) }
    @coord = Coord.new(0, 0)
    @coords = [@coord]
    @matrix = [['#']]
  end

  def solve
    make_coords
    shoelace_sum = shoelace
    perim = calc_perim
    picks(perim, shoelace_sum)
  end

  def picks(perim, shoelace)
    shoelace + (perim / 2) + 1
  end

  def calc_perim
    @lines.reduce(0) do |sum, (_, length)|
      sum + length
    end
  end

  def shoelace
    sum = 0
    @coords.each do |coord|
      next if coord.next.nil?

      next_coord = coord.next

      sum += coord.x * next_coord.y - coord.y * next_coord.x
    end
    sum / 2
  end

  def make_coords
    @lines.each_with_index do |(dir, count), i|
      prev = @coords[-1]
      new_coord = make_coord(dir, count, prev)
      @coords << new_coord
    end
  end

  def make_coord(dir, count, prev)
    case dir
    when 'U'
      move_up(count, prev)
    when 'D'
      move_down(count, prev)
    when 'L'
      move_left(count, prev)
    when 'R'
      move_right(count, prev)
    end
  end

  def move_up(count, prev)
    Coord.new(prev.x, prev.y - count).tap do |new_coord|
      prev.next = new_coord
    end
  end

  def move_down(count, prev)
    Coord.new(prev.x, prev.y + count).tap do |new_coord|
      prev.next = new_coord
    end
  end

  def move_left(count, prev)
    Coord.new(prev.x - count, prev.y).tap do |new_coord|
      prev.next = new_coord
    end
  end

  def move_right(count, prev)
    Coord.new(prev.x + count, prev.y).tap do |new_coord|
      prev.next = new_coord
    end
  end
end

s = Solver.new(lines)
puts s.solve

# expects 42317
