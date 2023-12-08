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

head = Node.head
steps = 0

until head.name == 'ZZZ'
  directions.each_with_index do |direction, i|
    case direction
    when 'L'
      head = head.left
    when 'R'
      head = head.right
    end
    steps += 1
  end
end

puts steps

# expect 11567
