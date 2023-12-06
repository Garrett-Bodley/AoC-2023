# frozen_string_literal: true

require 'pathname'
require 'pry-nav'

arg = ARGV.shift

case arg
when 'input'
  READ_FROM = 'input.txt'
when 'test'
  READ_FROM = 'test.txt'
else
  raise ArgumentError, "Expects 'input' or 'test' as command line argument"
end

File.open(File.join(__dir__, READ_FROM), 'r') do |file|

  data = []

  2.times do
    line = file.readline.chomp
    data << line.split(/\s+/)[1..].map(&:to_i)
  end

  times, distances = data

  winning = []

  times.each_with_index do |time, i|
    ways_to_win = 0
    time.times do |j|
      distance = distances[i]
      ms = j + 1
      remaining = time - ms
      travelled = remaining * ms
      ways_to_win += 1 if travelled > distance
    end
    winning << ways_to_win
  end
  puts winning.reduce(1) { |accum, val| accum * val }
end

# expect 503424
