# frozen_string_literal: true

require 'pathname'
require 'pry-nav'

# https://adventofcode.com/2023/day/4

base_path = Pathname.new(File.expand_path(__dir__))
input_path = base_path.parent.join('input.txt')
log_path = base_path.join('rlog1.txt')

input_file = File.open(input_path, File::RDONLY)
log_file = File.open(log_path, File::CREAT | File::RDWR | File::TRUNC)

cards = input_file.readlines(chomp: true)

sum = 0

cards.each_with_index do |card, index|
  # binding.pry
  hash = {}
  value = 0
  winning, provided = card.sub(/Card +\d+: +/, '').split('|').map(&:strip)
  winning.split(/ +/).sort{ |a, b| a.to_i - b.to_i }.each { |num| hash[num] = true}
  matches = provided.split(/ +/).sort{ |a, b| a.to_i - b.to_i }.select{ |num| hash[num] }
  match_set = Set.new(matches)
  # binding.pry
  value = 2**(match_set.length - 1) if match_set.length.positive?
  log_file.puts "Card #{index + 1}, Value: #{value}, Matches: #{matches.join(' ')}" if value > 0
  sum += value
end

log_file.puts sum
puts sum

# expect 21558

# 2695658400 too high!
# 94808 too high!
