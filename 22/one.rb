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

# Solves Day 22 Part 1
class Solver # rubocop:disable Metrics/ClassLength
  attr_accessor :bricks, :z_max, :layers, :top_bricks

  Hm = Class.new(StandardError)
  Brick = Struct.new(*%i[x y z])
  Node = Struct.new(*%i[brick underneath])

  def initialize(input)
    @input = input
    @bricks = []
    parse_input
    @height_matrix = build_height_matrix
    # binding.pry
    z_drop
    @z_max = max_height
    @layers = build_layers

    # @top_bricks = find_top_bricks
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

  def build_height_matrix
    x_max, y_max = xy_max
    Array.new(y_max + 1).map { Array.new(x_max + 1, 0) }
  end

  def underneath(brick)
    z_below = brick.z.begin - 1
    raise Hm if z_below < 0

    @layers[z_below].select { |br| xy_overlap?(brick, br) }
  end

  def collision?(brick1, brick2)
    r_overlap?(brick1.x, brick2.x) && r_overlap?(brick1.y, brick2.y) && r_overlap?(brick1.z, brick2.z)
  end

  def r_overlap?(r1, r2) # rubocop:disable Naming/MethodParameterName
    r1.end >= r2.begin && r2.end >= r1.begin
  end

  def xy_overlap?(brick1, brick2)
    r_overlap?(brick1.x, brick2.x) && r_overlap?(brick1.y, brick2.y)
  end

  # drop the bricks!
  def z_drop
    @bricks.sort { |a, b| a.z.begin <=> b.z.begin }.each{ |brick| drop_brick(brick) }
  end

  def drop_brick(brick) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    z_max = 0
    brick.y.each do |y|
      brick.x.each do |x|
        z_max = @height_matrix[y][x] if @height_matrix[y][x] > z_max
      end
    end
    raise Hm unless z_max < brick.z.begin

    z_offset = brick.z.begin - z_max - 1
    brick.z = (brick.z.begin - z_offset)..(brick.z.end - z_offset)

    brick.y.each do |y|
      brick.x.each do |x|
        @height_matrix[y][x] = brick.z.end
      end
    end
  end

  def max_height
    max_height = -Float::INFINITY
    @bricks.each do |brick|
      max_height = brick.z.end if brick.z.end > max_height
    end
    max_height
  end

  def build_layers
    # @layers is 1 indexed bc easier for my brain
    layers = Array.new(@z_max + 1).map { [] }
    @z_max.downto(1).each do |z|
      layer = layers[z]
      layer.concat(@bricks.select { |brick| brick.z.cover?(z) })
    end
    raise Hm unless layers[0].empty?

    layers
  end

  # Didn't end up needing this
  def find_top_bricks
    build_layers
    top_bricks = []
    @bricks.each do |brick|
      z_above = brick.z.end + 1
      next unless z_above > @z_max || @layers[z_above].none? { |br| xy_overlap?(brick, br) }

      top_bricks << brick
    end
    top_bricks
  end

  def xy_max
    x_max = -Float::INFINITY
    y_max = -Float::INFINITY
    @bricks.each do |brick|
      x_max = brick.x.end if brick.x.end > x_max
      y_max = brick.y.end if brick.y.end > y_max
    end
    [x_max, y_max]
  end

  def solve
    load_bearing = Set.new
    @bricks.select do |brick|
      underneath = underneath(brick)
      load_bearing.add(underneath[0]) if underneath.length == 1
    end

    @bricks.length - load_bearing.length
  end

  def offset_range(range, offset)
    ((range.begin + offset)..(range.end + offset))
  end

  def log_bricks
    @bricks.sort { |a, b| a.z.begin <=> b.z.begin }.each { |brick| puts brick }
  end
end

s = Solver.new(lines)
puts s.solve

# 227 too low
# 556 too high
# 541 too high
# expects 497
