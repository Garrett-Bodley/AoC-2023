# frozen_string_literal: true

require 'pathname'
require 'pry-nav'

# https://adventofcode.com/2023/day/4

base_path = Pathname.new(File.expand_path(__dir__))
input_path = base_path.parent.join('input.txt')
log_path = base_path.join('rlog2.txt')

input_file = File.open(input_path, File::RDONLY)
log_file = File.open(log_path, File::CREAT | File::RDWR | File::TRUNC)

cards = input_file.readlines(chomp: true)

sum = 0
match_count = []
card_count = []

cards.each_with_index do |card, index|
  card_count << 1
  hash = {}
  winning, provided = card.sub(/Card +\d+: +/, '').split('|').map(&:strip)
  winning.split(/ +/).sort{ |a, b| a.to_i - b.to_i }.each { |num| hash[num] = true}
  matches = provided.split(/ +/).sort{ |a, b| a.to_i - b.to_i }.select{ |num| hash[num] }
  match_set = Set.new(matches)
  # binding.pry
  value = match_set.length
  log_file.puts "Card #{index + 1}, Value: #{value}, Matches: #{matches.join(' ')}" if value.positive?
  i = 0
end

match_count.each_with_index do |val, index|
  next if val.zero?

  i = 1
  while i <= val && index + i < card_count.length
    card_count[index + i] += card_count[index]
    i += 1
  end
end

sum = card_count.reduce(0) {|accum, count| accum + count}

log_file.puts sum
puts sum

# 412471896367886799728790470616188 too high!
# 1719315 too low!
# 105634965697311493 too high!
