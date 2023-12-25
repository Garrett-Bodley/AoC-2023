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

# lines.map do |line|
#   node, dest = line.split(/:\s+/)
#   cs_dest = dest.split(' ').join(', ')
#   puts [node, cs_dest].join(' -- ') + ';'
# end

class Solver

  Node = Struct.new(*%i[name neighbors]) do
    def initialize(name = nil, neighbors = Set.new)
      super(name, neighbors)
    end

    def to_s
      "#{name}: #{neighbors.entries.join(' ')}"
    end

    def to_gv
      neighbors.entries.map { "#{name} -- #{_1};"}
    end
  end

  def initialize(input)
    @input = input
    @nodes = parse_input(input)
  end

  def solve
    # which ones to cut?
    # zgp -- cgt
    # fxk -- bcf
    # shj -- xhl

    # INPUT
    to_sever = [
      %w[zgp cgt],
      %w[fxk bcf],
      %w[shj xhl]
    ]

    # TEST
    # to_sever = [
    #   %w[hfx pzl],
    #   %w[bvb cmg],
    #   %w[nvd jqt]
    # ]

    cut_wires(to_sever)

    # zgp size
    sizes = to_sever[0].map { graph_size(@nodes[_1]) }
    sizes.reduce(1) { |product, val| product * val }
    # cgt size
  end

  def cut_wires(to_sever)
    to_sever.each do |a, b|
      @nodes[a].neighbors.delete(b)
      @nodes[b].neighbors.delete(a)
    end
  end

  def graph_size(node)
    visited = Set.new
    q = Queue.new
    q << node
    count = 0

    until q.empty?
      cur = q.pop
      next if visited.include?(cur)

      visited << cur
      count += 1
      cur.neighbors.entries.each do |neighbor|
        q << @nodes[neighbor] unless visited.include?(@nodes[neighbor] )
      end
    end
    count
  end

  def parse_input(input)
    hash = {}
    input.each do |line|
      nodes = line.scan(/\w{3}/)
      name = nodes[0]
      neighbors = nodes[1..]

      hash[name] = Node.new(name) if hash[name].nil?
      main = hash[name]

      neighbors.each do |neighbor|
        hash[neighbor] = Node.new(neighbor) if hash[neighbor].nil?

        other = hash[neighbor]
        main.neighbors << other.name
        other.neighbors << main.name
        # binding.pry
      end
    end
    hash
  end

  def gv_log
    @nodes.each_value do |node|
      node.to_gv.each { puts _1 }
    end
  end

end

# which ones to cut?
# zgp -- cgt
# fxk -- bcf
# shj -- xhl

s = Solver.new(lines)
puts s.solve
