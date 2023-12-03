# frozen_string_literal: true

require 'pathname'
require 'pry-nav'

# https://adventofcode.com/2023/day/3

base_path = Pathname.new(File.expand_path(__dir__))
input_path = base_path.parent.join('input.txt')
log_path = base_path.join('rlog1.txt')

input_file = File.open(input_path, File::RDONLY)
log_file = File.open(log_path, File::CREAT | File::RDWR | File::TRUNC)

lines = input_file.readlines(chomp: true)

def putsmatrix(matrix)
  matrix.each { |row| puts row.join('') }
end

def partnum?(num, ay, lines)
  pattern = /[!@\#$%^&*()_+={}\[\]:;"'<>,?\/\-~`|\\]/
  numstart = lines[ay].match(num).begin(0)
  numfinish = numstart + num.length

  matrix = []

  xstart = numstart > 0 ? numstart - 1 : numstart
  xfinish = numfinish < lines[ay].length ? numfinish + 1 : numfinish # EXCLUSIVE

  ystart = ay > 0 ? ay - 1 : ay
  yfinish = ay < lines.length - 1 ? ay + 2 : ay + 1

  if ay > 0
    y = ay - 1
    x = xstart
    while x < xfinish
      return true if lines[y][x].match?(pattern)

      x += 1
    end
  end

  y = ay
  x = xstart
  return true if lines[ay][xstart].match?(pattern)
  return true if lines[ay][xfinish - 1].match?(pattern)

  if ay < lines.length - 1
    y = ay + 1
    x = xstart
    while x < xfinish
      return true if lines[y][x].match?(pattern)

      x += 1
    end
  end

  false
end

sum = 0
lines.each_with_index do |line, linenum|
  # looking for numbers that are adjacent to other numbers
  # first lets find series of digits
  nums = line.scan(/\d+/)
  partnums = nums.select { |num| partnum?(num, linenum, lines) }
  rejected = nums.reject do |num|
    partnum?(num, linenum, lines)
  end
  partnums.each{ |num| sum += num.to_i }
  log_file.puts "#{linenum}: #{rejected.join(' ')}" if rejected.count > 0
end

log_file.puts(sum)
puts sum


# not 550371
