# frozen_string_literal: true

require 'pathname'
require 'pry-nav'

arg = ARGV.shift

case arg
when /input|input.txt/
  FILE_PATH = Pathname.new(File.expand_path('input.txt'))
when /test|test.txt/
  FILE_PATH = Pathname.new(File.expand_path('test.txt'))
else
  raise ArgumentError, "Expects 'input' or 'test' as command line argument"
end

lines = File.open(FILE_PATH, File::RDONLY).readlines(chomp: true).map { |line| line.split(/\s+/).map(&:to_i) }

def extrapolate(set)
  sets = [set]

  until sets[-1].all?(&:zero?)
    cur = sets[-1]
    new = []
    cur.each_with_index do |val, i|
      break if cur[i + 1].nil?

      new << cur[i + 1] - val
    end
    sets << new
  end
  sets.reverse!.each_with_index do |set, i|
    break if sets[i + 1].nil?

    sets[i + 1].push(sets[i + 1][-1] + set[-1])
  end

  sets[-1][-1]
end

res = lines.reduce(0) { |accum, line| accum + extrapolate(line) }

puts res

# expects 1834108701
