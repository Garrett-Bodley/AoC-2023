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
  def initialize(input)
    @input = input
    @z3 = Z3::Solver.new
  end

  def make_data
    @input.map do |line|
      line.scan(/-?\d+/).map(&:to_i)
    end
  end

  def solve # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    x = Z3.Int('x')
    y = Z3.Int('y')
    z = Z3.Int('z')

    vx = Z3.Int('vx')
    vy = Z3.Int('vy')
    vz = Z3.Int('vz')

    sol_vars = [x, y, z, vx, vy, vz]
    datas = make_data
    datas[0...3].each_with_index do |data, i|
      make_assertions(sol_vars, data, i)
    end
    puts @z3.assertions
    if @z3.satisfiable?
      vals = @z3.model.to_h
      vals[x].to_i + vals[y].to_i + vals[z].to_i
    else
      'wtf'
    end
  end

  def make_assertions(sol_vars, data, i) # rubocop:disable Metrics/AbcSize, Naming/MethodParameterName
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
