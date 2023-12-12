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
lines.unshift(Array.new(lines[0].length, '.'))
lines.push(Array.new(lines[0].length, '.'))

starty = lines.index { |l| l.any? { |c| c == 'S' } }
startx = lines[starty].index { |c| c == 'S' }

log_matrix = lines.map { |line| Array.new(line.length, ' ') }

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

  def self.flip_dir(dir)
    @@flip_dir[dir]
  end

  def self.dirs_to_shape(dirs) # rubocop:disable Metrics/CyclomaticComplexity, Metrics/MethodLength
    if dirs.include?('N')
      case dirs.reject { |el| el == 'N' }[0] # rubocop:disable Style/HashLikeCase
      when 'S'
        '|'
      when 'E'
        'L'
      when 'W'
        'J'
      end
    elsif dirs.include?('S')
      dirs.include?('E') ? 'F' : '7'
    else
      '-'
    end
  end
end
steps = [[Node.new(startx, starty, 'S', nil)]]
log_matrix[starty][startx] = 'S'

catch :break_cycle do
  loop do
    nodes = steps.last
    next_step = []
    nodes.each do |node|
      node.neighbors.each do |x, y, to_prev|
        shape = lines[y][x]
        next unless shape.match?(/[|\-LJ7FS]/) && Node.accessible?(shape, to_prev)

        lookup_key = "#{x},#{y}"
        throw :break_cycle unless Node.lookup[lookup_key].nil?

        log_matrix[y][x] = shape
        next_step << Node.new(x, y, shape, to_prev)
      end
    end
    steps << next_step
  end
end

# replace S with correct pipe segment in log_matrix

start = Node.all.find { |n| n.shape == 'S' }
connected = start.neighbors.filter do |x, y, to_prev|
  neighbor = Node.lookup["#{x},#{y}"]
  neighbor ? Node.accessible?(neighbor.shape, to_prev) : false
end
start_dirs = connected.map { |_, _, dir| Node.flip_dir(dir) }
start.shape = Node.dirs_to_shape(start_dirs)

log_matrix.each { |line| log_file.puts line.join('') }
log_file.flush

res_matrix = lines.map { |line| Array.new(line.length, false) }

(0...res_matrix.length).each do |y|
  line = res_matrix[y]

  borders_crossed = 0
  (0...line.length).each do |x|
    next if Node.lookup["#{x},#{y}"].nil? && borders_crossed.even?

    if !Node.lookup["#{x},#{y}"].nil? # if HAS LOOP PIPE
      shape = Node.lookup["#{x},#{y}"].shape

      case shape
      when '|'
        borders_crossed += 1
      when 'L'
        x += 1
        x += 1 while Node.lookup["#{x},#{y}"].shape == '-'
        borders_crossed += 1 if Node.lookup["#{x},#{y}"].shape == '7'
      when 'F'
        x += 1
        x += 1 while Node.lookup["#{x},#{y}"].shape == '-'
        borders_crossed += 1 if Node.lookup["#{x},#{y}"].shape == 'J'
      end
    elsif borders_crossed.odd?
      res_matrix[y][x] = true
    end
  end
end

fill_log_path = log_path.parent.join('fill_log.txt')
fill_log_file = File.open(fill_log_path, File::CREAT | File::RDWR | File::TRUNC)

res_matrix.each do |line|
  fill_log_file.puts line.map { |val| val == true ? '*' : ' '}.join('')
end

res = res_matrix.reduce(0) do |row_accum, row|
  row_accum + row.reduce(0) { |accum, val| val ? accum + 1 : accum }
end

puts res

# 384 too low!
# expects 411

# rubocop:enable Style/ClassVars
