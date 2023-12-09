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
    cycle[2] = node.name if cycle[2].nil?
    cycle
  end
end

cycles = Node.ghost_heads.map { |node| [node.name, has_cycle(node)] }
# binding.pry

ghost_heads = Node.ghost_heads
# binding.pry
steps = 0

cycle_lengths = cycles.map { |cycle| cycle[1][1] }

def gcd(a, b)
  return a if b.zero?

  gcd(b, a % b)
end

def lcm(a, b)
  (a * b) / gcd(a, b)
end

steps = cycle_lengths.reduce(directions.length) do |accum, l|
  lcm(accum, l)
end

puts steps

# 198134640 too low!
