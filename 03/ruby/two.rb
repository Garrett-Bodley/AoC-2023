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

sum = 0
lines.each_with_index do |line, linenum|
  # looking for numbers that are adjacent to other numbers
  # first lets find series of digits
  nums = line.enum_for(:scan, /\d+/).map { Regexp.last_match }

  # binding.pry
  partnums = nums.select do |num|
    partnum?(num, linenum, lines)
  end
  # binding.pry
  # rejected = nums.reject { |num| partnum?(num, linenum, lines)}
  partnums.each{ |num| sum += num[0].to_i }
  # log_file.puts "#{linenum}: #{rejected.join(' ')}"
end

log_file.puts(sum)
puts sum

# expect 550064
