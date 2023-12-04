# frozen_string_literal: true

require 'pathname'
require 'pry-nav'

# https://adventofcode.com/2023/day/4

base_path = Pathname.new(File.expand_path(__dir__))
input_path = base_path.parent.join('input.txt')

input_file = File.open(input_path, File::RDONLY)

cards = input_file.readlines(chomp: true)
card_count = Array.new(cards.length, 1)

cards.each_with_index do |card, index|
  winning, provided = card.sub(/Card +\d+: +/, '').split('|').map(&:strip)
  # binding.pry
  value = Set.new(winning.split(/ +/)).intersection(Set.new(provided.split(/ +/))).length
  (1..value).each do |offset|
    card_count[index + offset] += card_count[index]
  end
end

sum = card_count.reduce(0) { |accum, count| accum + count }

puts sum

# 10425665 expect

# 412471896367886799728790470616188 too high!
# 1719315 too high!
# 105634965697311493 too high!
