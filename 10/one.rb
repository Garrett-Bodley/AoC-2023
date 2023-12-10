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
  attr_accessor :x, :y

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


  def initialize(x, y, shape)
    @x = x
    @y = y
    @shape = shape
    @@lookup["#{shape}#{x}#{y}"] = self
    @@all << self
  end

  def neighbors(prev_dir = nil)
    directions = @@shape_directions[@shape].reject { |dir| dir == prev_dir }
    offsets = directions.map do |dir|
      x_offset, y_offset = @@dir_offsets[dir]
      [@x + x_offset, @y + y_offset]
    end

    offsets.map.with_index do |offset, i|
      [offset, directions[i]]
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

  def self.flip_dir(dir)
    @@flip_dir[dir]
  end
end
nodes = [[Node.new(startx, starty, 'S')]]
steps = 1

log_matrix[starty][startx] = 'S'

# [node, prevdir]
catch :break_cycle do
  loop do
    new_nodes = []
    nodes.each do |node, prev_dir|
      neighbors = node.neighbors(prev_dir)

      neighbor_nodes = neighbors.map do |(x, y), dir|
        shape = lines[y][x]
        next unless shape.match?(/[|\-LJ7FS]/)
        next unless Node.accessible?(shape, Node.flip_dir(dir))

        lookup_string = "#{shape}#{x}#{y}"

        unless Node.lookup[lookup_string].nil?
          puts steps
          throw :break_cycle
        end
        log_matrix[y][x] = shape
        [Node.new(x, y, shape), Node.flip_dir(dir)]
      end.compact
      new_nodes += neighbor_nodes
    end
    nodes = new_nodes
    puts steps
    steps += 1
  end
end

log_matrix.each { |line| log_file.puts line.join('') }

# 4100 too low!
