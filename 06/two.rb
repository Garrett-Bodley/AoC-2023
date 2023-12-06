# frozen_string_literal: true

require 'pathname'
require 'pry-nav'
require 'benchmark'

arg = ARGV.shift

case arg
when 'input'
  READ_FROM = 'input.txt'
when 'test'
  READ_FROM = 'test.txt'
else
  raise ArgumentError, "Expects 'input' or 'test' as command line argument"
end

def faster(filepath)

  File.open(File.join(__dir__, filepath), 'r') do |file|

    data = []

    2.times do
      line = file.readline.chomp
      data << line.split(/\s+/)[1..].join.to_i
    end

    times, distances = data.each_slice(1).to_a

    winning = []

    times.each_with_index do |time, i|
      ways_to_win = 0
      last = -Float::INFINITY
      time.times do |j|
        distance = distances[i]
        ms = j + 1
        remaining = time - ms
        travelled = remaining * ms
        break if travelled <= last

        last = travelled
        ways_to_win += 1 if travelled > distance
      end
      winning << ways_to_win * 2
    end
    puts winning.reduce(1) { |accum, val| accum * val }
  end
end

def slower(filepath)

  File.open(File.join(__dir__, filepath), 'r') do |file|

    data = []

    2.times do
      line = file.readline.chomp
      data << line.split(/\s+/)[1..].join.to_i
    end

    times, distances = data.each_slice(1).to_a

    winning = []

    times.each_with_index do |time, i|
      ways_to_win = 0
      last = -Float::INFINITY
      time.times do |j|
        distance = distances[i]
        ms = j + 1
        remaining = time - ms
        travelled = remaining * ms
        last = travelled
        ways_to_win += 1 if travelled > distance
      end
      winning << ways_to_win
    end
    puts winning.reduce(1) { |accum, val| accum * val }
  end
end

slow_time = Benchmark.measure do
  slower(READ_FROM)
end

fast_time = Benchmark.measure do
  faster(READ_FROM)
end

puts "fast: #{fast_time}"
puts "slow: #{slow_time}"

# expect 32607562
