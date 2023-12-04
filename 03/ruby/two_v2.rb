# rubocop:disable Style/RegexpLiteral, Metrics/BlockNesting
# frozen_string_literal: true

require 'pathname'
require 'pry-nav'

# https://adventofcode.com/2023/day/3

base_path = Pathname.new(File.expand_path(__dir__))
input_path = base_path.parent.join('input.txt')
# log_path = base_path.join('rlog1v2.txt')

input_file = File.open(input_path, File::RDONLY)
# log_file = File.open(log_path, File::CREAT | File::RDWR | File::TRUNC)

Sym = Struct.new(:char, :x, :y)
Num = Struct.new(:val, :x, :y, :length)

lines = input_file.readlines(chomp: true)
matrix = []
symbols = []
numbers = []

lines.each_with_index do |line, linenum|
  row = []
  x = 0
  while x < line.length
    case line[x]
    when '.'
      row[x] = Float::NAN
    when /[!@\#$%^&*()_+={}\[\]:;"'<>,?\/\-~`|\\]/
      row[x] = line[x]
      symbols << Sym.new(row[x], x + 1, linenum + 1)
    when /\d/
      start = x
      while line[x].match?(/\d/) && x < line.length - 1
        x += 1
      end
      x -= 1 unless x == 139
      finish = x
      num = line[start..finish].to_i
      (start..finish).each { |offset| row[offset] = num}
      length = finish - start + 1
      numbers << Num.new(num, start + 1, linenum + 1, length)
    end
    x += 1
  end
  matrix << [Float::NAN, *row, Float::NAN]
end

spacer = []
matrix[0].length.times { spacer << Float::NAN }
matrix.unshift(spacer)
matrix << spacer

def check_neighbors(sym, matrix, numbers) # rubocop:disable Metrics/AbcSize
  neighbors = []
  y_offset = -1
  while y_offset < 2
    x_offset = -1
    while x_offset < 2
      if y_offset == 0 # rubocop:disable Style/NumericPredicate
        left = matrix[sym.y][sym.x - 1]
        right = matrix[sym.y][sym.x + 1]
        if left.is_a?(Integer)
          left_num = numbers.select do |num|
            num.val == left && num.y == sym.y && (num.x..num.x + num.length - 1).cover?(sym.x - 1)
          end
          neighbors += left_num
        end
        if right.is_a?(Integer)
          right_num = numbers.select do |num|
            num.val == right && num.y == sym.y && (num.x..num.x + num.length - 1).cover?(sym.x + 1)
          end
          neighbors += right_num
        end
      else
        val = matrix[sym.y + y_offset][sym.x + x_offset]
        if val.is_a?(Integer)
          neighbor = numbers.select do |num|
            num.val == val && num.y == sym.y + y_offset && (num.x..num.x + num.length - 1).cover?(sym.x + x_offset)
          end
          neighbors += neighbor
          x_offset += 1 while matrix[sym.y + y_offset][sym.x + x_offset] == val
        end
      end
      x_offset += 1
    end
    y_offset += 1
  end
  neighbors
end

ratios = []
added = []

symbols.each do |sym|
  next unless sym.char == '*'

  neighbors = check_neighbors(sym, matrix, numbers)
  neighbors.reject! do |neighbor|
    reject = added.any? { |num| num.equal?(neighbor) }
    added << neighbor
    reject
  end
  if neighbors.length == 2
    ratio = neighbors[0].val * neighbors[1].val
    ratios << ratio
  end
end

total = ratios.reduce(0) { |accum, val| accum + val }

puts total

# expect 85010461

# rubocop:enable Style/RegexpLiteral, Metrics/BlockNesting
