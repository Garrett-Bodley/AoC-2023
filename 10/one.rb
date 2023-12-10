# rubocop:disable Style/ClassVars
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

log_path = Pathname.new(File.expand_path("#{FILE_PATH.basename('.*')}_log.txt"))
log_file = File.open(log_path, File::CREAT | File::RDWR | File::TRUNC)
lines = File.open(FILE_PATH, File::RDONLY).readlines(chomp: true).map{ |l| l.split('') }

lines.each do |line|
  line.unshift '.'
  line.push '.'
end
lines.unshift(Array.new(lines.length, '.'))
lines.push(Array.new(lines.length, '.'))

starty = lines.index { |l| l.any? { |c| c == 'S' } }
startx = lines[starty].index { |c| c == 'S' }

log_matrix = lines.map { |line| Array.new(line.length, ' ')}

# search neighbors to see if there are nearby pipes
#   what are the valid directions based on the current pipe piece?
#   Only search valid directions
# Keep moving down valid pathways until we return to S
#   This is a BFS algorithm!
#   Break loop when we've hit S

# Represents a node in the pipe matrix
class Node
  attr_accessor :x, :y, :shape, :to_prev

  @@all = []
  @@lookup = {}
  @@dir_offsets = {
    'N' => [0, -1],
    'S' => [0, 1],
    'E' => [1, 0],
    'W' => [-1, 0]
  }
  @@flip_dir = {
    'N' => 'S',
    'S' => 'N',
    'E' => 'W',
    'W' => 'E'
  }
  @@shape_directions = {
    '|' => %w[N S],
    '-' => %w[E W],
    'L' => %w[N E],
    'J' => %w[N W],
    'F' => %w[S E],
    '7' => %w[S W],
    'S' => %w[N S E W]
  }


  def initialize(x, y, shape, to_prev)
    @x = x
    @y = y
    @shape = shape
    @to_prev = to_prev
    @@lookup["#{x},#{y}"] = self
    @@all << self
  end

  def neighbors
    directions = @@shape_directions[@shape].reject { |dir| dir == @to_prev }
    directions.map do |dir|
      x_offset, y_offset = @@dir_offsets[dir]
      [@x + x_offset, @y + y_offset, @@flip_dir[dir]]
    end
  end

  def self.all
    @@all
  end

  def self.lookup
    @@lookup
  end

  def self.accessible?(shape, direction)
    @@shape_directions[shape].include?(direction)
  end

  # def self.flip_dir(dir)
  #   @@flip_dir[dir]
  # end
end
steps = [[Node.new(startx, starty, 'S', nil)]]
log_matrix[starty][startx] = 'S'

catch :break_cycle do
  loop do
    nodes = steps.last
    next_step = []
    nodes.each do |node|
      neighbors = node.neighbors.filter do |x, y, to_prev|
        shape = lines[y][x]
        shape.match?(/[|\-LJ7FS]/) && Node.accessible?(shape, to_prev)
      end
      neighbors.each do |x, y, to_prev|
        lookup_key = "#{x},#{y}"
        unless Node.lookup[lookup_key].nil?
          puts steps.length
          throw :break_cycle
        end
        shape = lines[y][x]
        log_matrix[y][x] = shape
        next_step << Node.new(x, y, shape, to_prev)
      end
    end
    steps << next_step
  end
end

log_matrix.each { |line| log_file.puts line.join('') }

# 4100 too low!
# expects 6640
