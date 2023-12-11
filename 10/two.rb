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

log_matrix.each { |line| log_file.puts line.join('') }

x_scan_matrix = lines.map { |line| Array.new(line.length, false) }
y_scan_matrix = lines.map { |line| Array.new(line.length, false) }
res_matrix = lines.map { |line| Array.new(line.length, false) }

# x_scan_matrix.map!.with_index do |line, y|
#   borders_crossed = 0
#   prev = false
#   line.map.with_index do |_, x|
#     if Node.lookup["#{x},#{y}"].nil?
#       borders_crossed += 1 if prev == true
#       prev = false
#       (borders_crossed % 2).zero? ? false : true
#     else
#       prev = true
#       false
#     end
#   end
# end
#

(0...x_scan_matrix.length).each do |y|
  line = x_scan_matrix[y]
  prev_border = false
  start = 0
  finish = 0
  (0...line.length).each do |x|
    next if Node.lookup["#{x},#{y}"].nil? && prev_border == false

    if !Node.lookup["#{x},#{y}"].nil? # if HAS LOOP PIPE
      prev_border = true
      x += 1 until Node.lookup["#{x},#{y}"].nil?
      start = x
      x += 1 while Node.lookup["#{x},#{y}"].nil? && x < line.length
      next if x >= line.length

      (start...x).each { |fill_x| line[fill_x] = true }
      x -= 1
    end
  end
end

(0...y_scan_matrix[0].length).each do |x|

  prev_border = false
  (0...y_scan_matrix.length).each do |y|
    next if Node.lookup["#{x},#{y}"].nil? && prev_border == false

    if !Node.lookup["#{x},#{y}"].nil? # if HAS LOOP PIPE
      prev_border = true
      y += 1 until Node.lookup["#{x},#{y}"].nil?
      start = y
      y += 1 while Node.lookup["#{x},#{y}"].nil? && y < lines.length
      next if y >= lines.length

      (start...y).each { |fill_y| y_scan_matrix[fill_y][x] = true }
      y -= 1
    end
  end
end

# given a line
# scan through the line
# I want to if line[x] has node to left and to right it is inside
# going from left to right:
#   is there a preceding left node?
#     continue until we hit a right node or EOL
#   no preceding left node?
#     ignore

res = 0
(0...x_scan_matrix.length).each do |y|
  xline = x_scan_matrix[y].map { |val| val ? '*' : ' ' }.join('')
  yline = y_scan_matrix[y].map { |val| val ? '*' : ' ' }.join('')
  x_groups = xline.enum_for(:scan, /\*+/).map { Regexp.last_match }
  x_groups.each do |x_group|
    next if yline.slice(x_group.begin(0), x_group[0].length).match?(/\s+/)

    start = x_group.begin(0)
    finish = start + x_group[0].length
    (start...finish).each do |x|
      res_matrix[y][x] = true
    end
  end
end

xscan_path = log_path.parent.join('xscan.txt')
yscan_path = log_path.parent.join('yscan.txt')
fill_log_path = log_path.parent.join('fill_log.txt')

xscan_file = File.open(xscan_path, File::CREAT | File::RDWR | File::TRUNC)
yscan_file = File.open(yscan_path, File::CREAT | File::RDWR | File::TRUNC)
fill_log_file = File.open(fill_log_path, File::CREAT | File::RDWR | File::TRUNC)

x_scan_matrix.each do |line|
  xscan_file.puts line.map { |val| val == true ? '*' : ' ' }.join('')
end

y_scan_matrix.each do |line|
  yscan_file.puts line.map { |val| val == true ? '*' : ' ' }.join('')
end

res_matrix.each do |line|
  fill_log_file.puts line.map { |val| val == true ? '*' : ' '}.join('')
end

# binding.pry
res = res_matrix.reduce(0) do |row_accum, row|
  row_accum + row.reduce(0) { |accum, val| val ? accum + 1 : accum }
end

puts res

# 384 too low!

# rubocop:enable Style/ClassVars
