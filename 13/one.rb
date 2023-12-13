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

lines = File.open(FILE_PATH, File::RDONLY).readlines(chomp: true)

log_path = FILE_PATH.parent.join("#{FILE_PATH.basename('.*')}_log.txt")
log_file = File.open(log_path, 'w+')

puzzles = []
puzzle = []

puzzles = lines.slice_before('').map { |chunk| chunk.reject(&:empty?) }
binding.pry

puzzles.each do |puzzle|
  puzzle.each { |line| log_file.puts line }
  log_file.puts
end
