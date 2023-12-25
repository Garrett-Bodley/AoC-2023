# rubocop:disable Style/NumericPredicate
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

# Solves Day 24 Part 1
class Solver

  Hail = Struct.new(*%i[x y z vx vy vz]) do
    INVALID_PATH = [-Float::INFINITY..-Float::INFINITY] * 2 # rubocop:disable Lint/ConstantDefinitionInBlock

    def calc_path(xy_range)
      # what happens to these equations if x < xy_range.begin && vx.negative?
      # I have to figure out what I'm going to return from this function lol

      # am I moving left or right?
      # right now I'm always assuming I"m moving left
      # what if I'm entering from the right to the left
      # what if I'm entering from the top to the bottom?
      # oh no
      # binding.pry
      # return INVALID_PATH if x < xy_range.begin && vx <= 0
      # return INVALID_PATH if x > xy_range.end && vx >= 0
      # return INVALID_PATH if y < xy_range.begin && vy <= 0
      # return INVALID_PATH if y > xy_range.end && vy >= 0

      # if vx <= 0
      #   x_path = x_path_left(xy_range)
      # else
      #   x_path = x_path_right(xy_range)
      # end
      # binding.pry
      to_xstart = time_to_target(x, xy_range.begin, vx)
      to_xend = time_to_target(x, xy_range.end, vx)

      to_ystart = time_to_target(y, xy_range.begin, vy)
      to_yend = time_to_target(y, xy_range.end, vy)

      # binding.pry if to_xstart > to_xend || to_ystart > to_yend
      # return INVALID_PATH if to_xstart > to_xend || to_ystart > to_yend

      # THIS IS ALL TIME STUFF
      x_min_t = [to_xstart, to_xend].min
      x_max_t = [to_xstart, to_xend].max

      y_min_t = [to_ystart, to_yend].min
      y_max_t = [to_ystart, to_yend].max

      # Find time frame within given xy range
      time_frame = [x_min_t, y_min_t].max..[x_max_t, y_max_t].min

      x_start = x + vx * time_frame.begin
      x_end = x + vx * time_frame.end
      # x_range = x_start..x_end

      # Hacky and Bad
      x_range = [x_start, x_end].min..[x_start, x_end].max

      y_start = y + vy * time_frame.begin
      y_end = y + vy * time_frame.end
      # y_range = y_start..y_end

      y_range = [y_start, y_end].min..[y_start, y_end].max

      binding.pry unless r_overlap?(x_range, xy_range) && r_overlap?(y_range, xy_range)
      return INVALID_PATH unless r_overlap?(x_range, xy_range) && r_overlap?(y_range, xy_range)

      [x_range, y_range]
    end

    def time_to_target(start, target, vector)
      return 0 if start == target

      if start < target && vector > 0 || start > target && vector < 0
        # positive time
        t = (target - start) / vector
      elsif start < target && vector < 0 || start > target && vector > 0
        # negative time
        t = -(target - start / vector)
      elsif start > target && vector == 0
        -Float::INFINITY
      elsif start < target && vector == 0
        Float::INFINITY
      end
    end

    # def x_path_left

    # end

    # def x_path_right

    # end

    # def y_path_down

    # end

    # def y_path_up

    # end

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
    paths = @hail.map { |h| [h, h.calc_path(@xy_range)] }
                 .reject { _1[1].include?([-Float::INFINITY..-Float::INFINITY] * 2) }

    binding.pry unless paths.select { _1.include?([-Float::INFINITY..-Float::INFINITY] * 2) }.empty?

    collisions = Set.new

    (0...paths.length - 1).each do |i|
      h, (x_range, y_range) = paths[i]
      ((i + 1)...paths.length).each do |j|
        cmp_h, (cmp_x_range, cmp_y_range) = paths[j]
        binding.pry if cmp_h.x == 12

        if r_overlap?(x_range, cmp_x_range) && r_overlap?(y_range, cmp_y_range)
          collisions << h
          collisions << cmp_h
        end
      end
    end

    binding.pry
    # paths.map do |path|
    #   h, (x_range, y_range) = path
    #   others = paths.reject { _1 == path }



    # end
  end

  def r_overlap?(r1, r2) # rubocop:disable Naming/MethodParameterName
    r1.end >= r2.begin && r2.end >= r1.begin
  end


end

# xy_range = 200_000_000_000_000..400_000_000_000_000
test_range = 7..27

s = Solver.new(lines, test_range)
s.solve

# rubocop:enable Style/NumericPredicate
