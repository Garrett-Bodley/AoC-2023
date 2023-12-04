# frozen_string_literal: true

require 'pathname'
require 'pry-nav'

# https://adventofcode.com/2023/day/3

base_path = Pathname.new(File.expand_path(__dir__))
input_path = base_path.parent.join('input.txt')
log_path = base_path.join('rlog2.txt')

input_file = File.open(input_path, File::RDONLY)
log_file = File.open(log_path, File::CREAT | File::RDWR | File::TRUNC)

lines = input_file.readlines(chomp: true)

def partnum?(num, y, lines)
  pattern = /[!@\#$%^&*()_+={}\[\]:;"'<>,?\/\-~`|\\]/
  start = num.begin(0)
  finish = start + num[0].length - 1

  (start..finish).each do |x|
    if y > 0
      return true if x > 0 && lines[y - 1][x - 1].match?(pattern)
      return true if lines[y - 1][x].match?(pattern)
      return true if x < lines[y].length - 1 && lines[y - 1][x + 1].match?(pattern)
    end

    return true if x > 0 && lines[y][x - 1].match?(pattern)
    return true if x < lines[y].length - 1 && lines[y][x + 1].match?(pattern)

    if y < lines.length - 1
      return true if x > 0 && lines[y + 1][x - 1].match?(pattern)
      return true if lines[y + 1][x].match?(pattern)
      return true if x < lines[y].length - 1 && lines[y + 1][x + 1].match?(pattern)
    end

  end

  false
end

def find_ratio(gear, geary, lines)
  gearx = gear.begin(0)
  xstart = gearx > 0 ? gearx - 1 : gearx
  xend = gearx < lines[0].length - 1 ? gearx + 1 : gearx

  ystart = geary > 0 ? geary - 1 : geary
  yend = geary < lines.length - 1 ? geary + 1 : geary

  y = ystart

  neighbors = []

  while y <= yend
    line_nums = lines[y].enum_for(:scan, /\d+/).map { Regexp.last_match }

    line_nums.select! do |num_match_data|
      num_start = num_match_data.begin(0)
      num_last = num_match_data.end(0) - 1
      num_range = (num_start..num_last).to_a
      num_range.any? { |x| (xstart..xend).cover?(x) }
    end
    # binding.pry
    line_nums.each { |match| neighbors << match[0].to_i }
    return neighbors[0] * neighbors[1] if neighbors.length > 1

    y += 1
  end
  0
end

sum = 0
lines.each_with_index do |line, linenum|
  # looking for numbers that are adjacent to other numbers
  # first lets find series of digits
  gears = line.enum_for(:scan, /\*/).map { Regexp.last_match }

  # binding.pry
  gears.each do |gear|
    ratio = find_ratio(gear, linenum, lines)
    log_file.puts "Gear on line: #{linenum}, ratio: #{ratio}" if ratio > 0
    sum += ratio
  end
end

puts sum

# expect 85010461
