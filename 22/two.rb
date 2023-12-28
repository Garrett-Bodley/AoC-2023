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

lines = File.open(FILE_PATH, File::RDONLY).readlines(chomp: true)

# Solves Day 22 Part 2
class Solver
  Brick = Struct.new(*%i[x y z]) do
    def all_points
      x.to_a.product(y.to_a).product(z.to_a).map(&:flatten)
    end
  end

  def initialize(input)
    @input = input
    @bricks = []
    @grid = {}
    parse_input
  end

  def parse_input # rubocop:disable Metrics/AbcSize
    @input.each do |line|
      data = line.split('~').map { |chunk| chunk.split(',').map(&:to_i) }
      xstart, ystart, zstart = data[0]
      xend, yend, zend = data[1]

      # Is the input annoying?
      raise Hm if xstart > xend
      raise Hm if ystart > yend
      raise Hm if zstart > zend

      # no

      @bricks << Brick.new((xstart..xend), (ystart..yend), (zstart..zend))
    end
  end

  def drop_bricks
    @bricks.sort { |a, b| a.z.begin <=> b.z.begin }.each do |brick|
      drop_brick(brick)
    end
  end

  def drop_brick(brick) # rubocop:disable Metrics/AbcSize
    until brick.z.begin == 1
      points = brick.all_points
      break if points.any? { |x, y, z| @grid[[x, y, z - 1]] && @grid[[x, y, z - 1]] != brick }

      points.each do |x, y, z|
        @grid.delete([x, y, z])
        @grid[[x, y, z - 1]] = brick
      end

      brick.z = dec_range(brick.z)
    end
  end

  def map_bricks
    @bricks.each do |brick|
      brick.all_points.each do |points|
        @grid[points] = brick
      end
    end
  end

  def map_above
    @above = @bricks.map do |brick|
      above = brick.all_points.map { |x, y, z| @grid[[x, y, z + 1]] if @grid[[x, y, z + 1]] != brick }.compact.to_set
      [brick, above]
    end.to_h
  end

  def map_below
    @below = @bricks.map do |brick|
      below = brick.all_points.map { |x, y, z| @grid[[x, y, z - 1]] if @grid[[x, y, z - 1]] != brick }.compact.to_set
      [brick, below]
    end.to_h
  end

  def dec_range(range)
    (range.begin - 1)..(range.end - 1)
  end

  def solve # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    map_bricks
    drop_bricks
    map_above
    map_below

    @bricks.sort { |a, b| a.z.begin <=> b.z.begin }.sum do |brick|
      felled = [brick].to_set
      q = @above[brick].to_a

      while cur = q.shift
        next if felled.include?(cur)
        next unless @below[cur].all? { felled.include?(_1) }

        felled.add(cur)
        q += @above[cur].to_a
      end

      felled.count - 1
    end
  end
end

s = Solver.new(lines)
puts s.solve

# expects 67468
