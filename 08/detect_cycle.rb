require 'pry-nav'

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

  def self.count
    @all.count
  end

  def to_s
    "Name: #{@name}, Left: #{@left&.name}, Right: #{@right&.name}"
  end
end


nodes = []
nodes.push %w[ a b c ]
nodes.push %w[ b d e ]
nodes.push %w[ c f g ]
nodes.push %w[ d a h ]

nodes.map do |edge|
  n, l, r = edge
  node = Node.lookup[n] || Node.new(n)
  lnode = Node.lookup[l] || Node.new(l)
  rnode = Node.lookup[r] || Node.new(r)

  node.left = lnode
  node.right = rnode
end

def has_cycle(node, visited = {}, length = 0)
  return [false, 0] if node.nil?
  return [true, length] if visited[node]

  binding.pry if node.name == 'd'
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

cycle_check = Node.all.map do |node|
  cycle = has_cycle(node)
  [node.name, cycle]
end

binding.pry
