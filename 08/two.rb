# frozen_string_literal: true

require 'pathname'
require 'pry-nav'

arg = ARGV.shift

case arg
when /input|input.txt/
  FILE_PATH = Pathname.new(File.expand_path('input.txt'))
when /test1|test1.txt/
  FILE_PATH = Pathname.new(File.expand_path('test1.txt'))
when /test2|test2.txt/
  FILE_PATH = Pathname.new(File.expand_path('test2.txt'))
when /test3|test3.txt/
  FILE_PATH = Pathname.new(File.expand_path('test3.txt'))
else
  raise ArgumentError, "Expects 'input', 'test1', or 'test2' as command line argument"
end

file = File.open(FILE_PATH, File::RDONLY)
lines = file.readlines(chomp: true)

directions = lines.shift.split('')

class Node
  attr_reader :name
  attr_accessor :left, :right

  @all = []
  @lookup = {}
  def initialize(name)
    @name = name
    self.class.all << self
    self.class.lookup[name] = self
  end

  def self.all
    @all
  end

  def self.head
    @lookup['AAA']
  end

  def self.ghost_heads
    @all.select { |node| node.name[-1] == 'A' }
  end

  def self.lookup
    @lookup
  end
end

lines.shift

lines.each do |line|
  name, left, right = line.match(/^(\w+) = \((\w+), (\w+)\)/).to_a[1..]

  node = Node.lookup[name] || Node.new(name)
  lnode = Node.lookup[left] || Node.new(left)
  rnode = Node.lookup[right] || Node.new(right)

  node.left = lnode
  node.right = rnode
end

def has_cycle(node, visited = {}, length = 0)
  return [false, 0] if node.nil?
  return [true, length] if visited[node]

  # binding.pry if node.name == 'd'
  visited[node] = true
  l = has_cycle(node.left, visited, length + 1)
  r = has_cycle(node.right, visited, length + 1)
  cycle = [l, r].select { |c| c[0] == true }[0]


  if cycle.nil?
    [false, 0]
  else
    if cycle[2].nil?
      cycle[2] = node.name
      cycle[3] = l[0] == true ? 'left' : 'right'
      cycle[4] = l[0] == true ? node.left.name : node.right.name
    end
    cycle
  end
end

def cycle_log(node, directions, visited)
  steps = 0
  visited = {}
  loop do
    (0...directions.length).each do |i|
    end
  end
end

cycles = Node.ghost_heads.map { |node| [node.name, has_cycle(node)] }

def find_lead_in(head, start, directions)
  count = 0
  loop do
    directions.each do |dir|
      return count if head == start

      case dir
      when 'L'
        head = head.left
      when 'R'
        head = head.right
      end
      count += 1
    end
  end
end

# cycles:
# [HEAD, [TRUE, LENGTH, LAST, DIRECTION_TO_START, START, LEAD_IN_FROM_HEAD_TO_START, DISTANCE_HEAD_TO_Z]]

cycles.each do |cycle|
  head = cycle[0]
  start = cycle[1][4]
  lead_in = find_lead_in(Node.lookup[head], Node.lookup[start], directions)
  cycle[1].push lead_in
end

def distance_head_to_z(node, directions)
  count = 0
  loop do
    directions.each do |dir|
      return count if node.name[-1] == 'Z'
      case dir
      when 'L'
        node = node.left
      when 'R'
        node = node.right
      end
      count += 1
    end
  end
end

cycles.each do |cycle|
  head = cycle[0]
  cycle[1].push distance_head_to_z(Node.lookup[head], directions)
end

def dir_cycle_length(node, directions)
  visited = {}
  count = 0
  loop do
    directions.each_with_index do |dir, i|
      if visited[node]
        return count - visited[node][:count] if visited[node][:dir_i] == i
      else
        visited[node] = { count: count, dir_i: i }
      end
      node = dir == 'L' ? node.left : node.right
      count += 1
    end
  end
end

dirlens = cycles.each do |cycle|
  head = Node.lookup[cycle[0]]
  cycle[1].push dir_cycle_length(head, directions)
end
binding.pry

cycle_lengths = cycles.map { |cycle| cycle[1][1] }

def gcd(a, b)
  return a if b.zero?

  gcd(b, a % b)
end

def lcm(a, b)
  (a * b) / gcd(a, b)
end

steps = cycles.reduce(directions.length) do |accum, cycle|
  dir_cycle_length = cycle[1][-1]
  lcm(accum, dir_cycle_length)
end

puts steps

# 198134640 too low!
# 324371682847328190320400 too high!

# expects 9858474970153
