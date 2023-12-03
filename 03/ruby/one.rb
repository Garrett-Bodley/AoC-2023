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
  xfinish = numfinish < lines[ay].length ? numfinish + 1 : numfinish

  ystart = ay > 0 ? ay - 1 : ay
  yfinish = ay < lines.length - 1 ? ay + 2 : ay + 1

  # lets go line by line!
  y = ystart
  while y < yfinish
    j = xstart
    row = []
    x = xstart
    while x < xfinish
      row << lines[y][x]
      x += 1
    end
    matrix << row
    y += 1
  end
  putsmatrix(matrix)

  # # check first char

  # # check preceding above, inline, and below of first char
  # return true if x > 0 && y > 0 && lines[y - 1][x - 1].match?(pattern)
  # return true if x > 0 && lines[y][x - 1].match?(pattern)
  # return true if x > 0 && y < lines.length - 1 && lines[y + 1][x - 1].match?(pattern)

  # # check above and below all chars

  # while x < finish
  #   return true if y > 0 && lines[y - 1][x].match?(pattern)
  #   return true if y < lines.length - 1 && lines[y + 1][x].match(pattern)

  #   x += 1
  # end

  # # check postceding above, inline, and below of last char

  # return true if x < lines[y].length - 1 && y > 0 && lines[y - 1][x + 1].match?(pattern)
  # return true if x < lines[y].length - 1 && lines[y][x + 1].match?(pattern)
  # return true if x < lines[y].length - 1 && y < lines.length - 1 && lines[y + 1][x + 1].match?(pattern)

  matrix_string = matrix.map{ |row| row.join('') }.join('')
  valid = matrix_string.match?(pattern)
  # binding.pry if numfinish == lines[y].length - 1 || numstart == 0
  # binding.pry if ay == 0 || ay == lines.length - 1
  # binding.pry if num == "169"

  valid
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
