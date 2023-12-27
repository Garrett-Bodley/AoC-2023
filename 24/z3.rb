# frozen_string_literal: true

require 'pathname'
require 'pry-nav'
require 'z3'

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

class MySolver

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

  def initialize(input)
    @input = input
    @hail = []
    @z3 = Z3::Solver.new
    init_hail
  end

  def init_hail
    @input.each do |line|
      @hail << Hail.new(*line.scan(/-?\d+/).map(&:to_f))
    end
  end

  def make_data
    @input.map do |line|
      line.scan(/-?\d+/).map(&:to_f)
    end
  end

  def solve
    x = Z3.Int('x')
    y = Z3.Int('y')
    z = Z3.Int('z')

    vx = Z3.Int('vx')
    vy = Z3.Int('vy')
    vz = Z3.Int('vz')

    sol_vars = [x, y, z, vx, vy, vz]
    datas = make_data
    datas[0..2].each_with_index do |data, i|
      make_assertions(sol_vars, data, i)
    end

    if @z3.satisfiable?
      vals = @z3.model.to_h
      vals[x].to_i + vals[y].to_i + vals[z].to_i
    else
      'wtf'
    end
  end

  def make_assertions(sol_vars, data, i)
    x, y, z, vx, vy, vz = sol_vars
    dx, dy, dz, dvx, dvy, dvz = data

    t = Z3.Int("t#{i}")

    @z3.assert dx + dvx * t == x + vx * t
    @z3.assert dy + dvy * t == y + vy * t
    @z3.assert dz + dvz * t == z + vz * t

  end

end

s = MySolver.new(lines)
puts s.solve
