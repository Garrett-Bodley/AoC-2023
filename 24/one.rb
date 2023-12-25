# rubocop:disable Style/NumericPredicate
# frozen_string_literal: true

require 'pathname'
require 'pry-nav'

arg = ARGV.shift

case arg
when /input|input.txt/
  FILE_PATH = Pathname.new(File.expand_path('input.txt'))
  RANGE = (200_000_000_000_000..400_000_000_000_000).freeze
when /test|test.txt/
  FILE_PATH = Pathname.new(File.expand_path('test.txt'))
  RANGE = (7..27).freeze
else
  raise ArgumentError, "Expects 'input' or 'test' as command line argument"
end

lines = File.open(FILE_PATH, File::RDONLY).readlines(chomp: true)

# Solves Day 24 Part 1
class Solver
  Hail = Struct.new(*%i[x y z vx vy vz]) do
    INVALID_PATH = [-Float::INFINITY..-Float::INFINITY] * 2 # rubocop:disable Lint/ConstantDefinitionInBlock

    def slope
      vy / vx
    end

    def y_intercept
      # mx + b = y
      # b = y - mx
      y - slope * x
    end

    def intersection(h2)
      if parallel?(h2)
        return true if y_intercept == h2.y_intercept # rubocop:disable Layout/EmptyLineAfterGuardClause
        return false
      end

      x_collide = x_intersection(h2)
      y1_collide = y_at_x(x_collide)
      y2_collide = h2.y_at_x(x_collide)

      # not equivalent bc of float value drift
      # will this bite me in the but later?
      # binding.pry if y1_collide != y2_collide

      [x_collide, y1_collide]
    end

    def time_at_x(arg_x)

      (arg_x - x) / vx
    end

    def parallel?(h2)
      slope == h2.slope
    end

    def x_intersection(h2)
      (h2.y_intercept - y_intercept) / (slope - h2.slope)
    end

    def y_at_x(a_x)
      # y = mx + b
      slope * a_x + y_intercept
    end

    def r_overlap?(r1, r2) # rubocop:disable Naming/MethodParameterName
      r1.end >= r2.begin && r2.end >= r1.begin
    end

  end

  def initialize(input, xy_range)
    @input = input
    @hail = []
    @xy_range = xy_range
    init_hail
  end

  def init_hail
    @input.each do |line|
      @hail << Hail.new(*line.scan(/-?\d+/).map(&:to_f))
    end
  end

  def solve
    collisions = []

    (0...@hail.length - 1).each do |i|
      h1 = @hail[i]
      ((i + 1)...@hail.length).each do |j|
        h2 = @hail[j]
        intersection = h1.intersection(h2)
        next if intersection == false

        # problem at 18,19 and 20,25

        if intersection == true
          [h1, h2].each { collisions << _1 }
          next
        end
        h1_time = h1.time_at_x(intersection[0])
        h2_time = h2.time_at_x(intersection[0])

        collisions << [h1, h2] if intersection.all? { @xy_range.cover?(_1) } && h1_time > 0 && h2_time > 0
      end
    end

    puts collisions.count
  end

  def r_overlap?(r1, r2) # rubocop:disable Naming/MethodParameterName
    r1.end >= r2.begin && r2.end >= r1.begin
  end
end

s = Solver.new(lines, RANGE)
s.solve

# expects 26657

# rubocop:enable Style/NumericPredicate
