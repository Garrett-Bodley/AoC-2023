# frozen_string_literal: true

require 'pathname'
require 'pry-nav'
require 'rb_heap'

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

# Solves Day 23 Part 2
class Solver
  Coord = Struct.new(*%i[x y steps char path]) do
    def to_s
      "#{x},#{y}"
    end
  end

  Node = Struct.new(*%i[coord neighbors] ) do
    def initialize(coord, neighbors = {})
      super(coord, neighbors)
    end

    def add_edge(coord, distance)
      neighbors[coord] = distance
    end
  end

  def initialize(input)
    @matrix = input.map { _1.split('') }
    find_junctions
    build_graph
  end

  # def dijkstra(target = Coord.new(@matrix[0].length - 2, @matrix.length - 1)) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  #   start = Coord.new(1, 0, 0)
  #   start.char = @matrix[0][1]
  #   start.path = Set.new
  #   heap = Heap.new { |a, b| a.steps > b.steps }
  #   heap.add(start)
  #   visited = {}

  #   until heap.empty?
  #     cur = heap.pop

  #     neighbors = get_neighbors(cur)
  #     filtered = neighbors.map do |coord|
  #       visited[coord.to_s] = coord if visited[coord.to_s].nil? || coord.steps > visited[coord.to_s].steps
  #     end.compact

  #     filtered.each { heap.add(_1) }
  #   end
  #   visited[target.to_s].steps
  # end

  def find_junctions
    puts 'finding junctions'
    @junctions = []
    (0...@matrix.length).each do |y|
      (0...@matrix[0].length).each do |x|
        char = @matrix[y][x]
        next if char == '#'

        north = @matrix[y - 1][x] if y > 0
        south = @matrix[y + 1][x] if y < @matrix.length - 2
        east = @matrix[y][x + 1] if x < @matrix[0].length - 2
        west = @matrix[y][x - 1] if x > 0

        neighbors = [north, south, east, west].compact.reject { _1 == '#' }
        @junctions << Coord.new(x, y, 0, @matrix[y][x]) if neighbors.length > 2
      end
    end
    # Starting Point
    @junctions << Coord.new(1, 0, 0, '.')
    # End Point
    @junctions << Coord.new(@matrix[0].length - 2, @matrix.length - 1, 0, '.')
  end

  def find_junction_distances
    puts 'finding junction distances'
    edges = []
    @junctions.each do |junction|
      # generates a pair w/every other junction
      pairs = [junction].product(@junctions.reject { _1 == junction })
      # compute max distance via brute force for each junction
      edges += pairs.map { find_junction_distance(_1) }.reject { _1[1] == -Float::INFINITY }
    end
    edges.reject { _1[1] == -Float::INFINITY }
  end

  def find_junction_distance(pair)
    start, target = pair.map(&:dup)
    # List of other junctions minus the current pair
    reject = @junctions.reject { _1 == start || _1 == target }.map(&:to_s)
    start.path = Set.new
    stack = [start]
    longest = -Float::INFINITY
    until stack.empty?
      cur = stack.pop
      # abandon paths that lead to other junctions
      next if reject.include?(cur.to_s)

      if cur.x == target.x && cur.y == target.y
        longest = [longest, cur.steps].max
        next
      end

      neighbors = get_neighbors(cur)
      stack += neighbors
    end
    [start, longest, target]
  end

  def build_graph
    puts 'building graph'
    edges = find_junction_distances
    @graph = {}
    edges.each do |from, distance, to|
      @graph[from.to_s] = Node.new(from.to_s) if @graph[from.to_s].nil?
      node = @graph[from.to_s]
      node.add_edge(to.to_s, distance)
    end
  end

  def graph_traverse
    puts 'traversing graph'
    start = @graph['1,0']
    target = @graph["#{@matrix[0].length - 2},#{@matrix.length - 1}"]

    # This is really gross but I didn't feel like writing a proper struct for each stack frame
    # node, steps, visited
    stack = [[start, 0, Set.new]]
    longest = -Float::INFINITY

    until stack.empty?
      node, distance, visited = stack.pop

      if node.coord == target.coord
        longest = [longest, distance].max
        next
      end


      visited << node.coord

      neighbors = node.neighbors.to_a.map do |coord, cost|
        [@graph[coord], distance + cost, visited.dup] unless visited.include?(coord)
      end.compact
      stack += neighbors
    end
    longest
  end

  # Too slow even when if I try the trick of logging each new longest route
  # def brute_force
  #   target = Coord.new(@matrix[0].length - 2, @matrix.length - 1)
  #   start = Coord.new(1, 0, 0)
  #   start.char = @matrix[0][1]
  #   start.path = Set.new
  #   stack = [start]

  #   longest = -Float::INFINITY

  #   until stack.empty?
  #     cur = stack.pop
  #     if cur.x == target.x && cur.y == target.y
  #       if cur.steps > longest
  #         longest = cur.steps
  #         puts longest
  #       end
  #       next
  #     end

  #     neighbors = get_neighbors(cur)
  #     stack += neighbors
  #   end
  #   longest
  # end

  def get_neighbors(coord)
    neighbors = [north(coord), south(coord), east(coord), west(coord)].compact
    neighbors.reject { coord.path.include?(_1.to_s) }
  end

  def north(coord)
    return nil if coord.y == 0

    new_y = coord.y - 1
    char = @matrix[new_y][coord.x]
    return nil if char == '#'

    Coord.new(coord.x, new_y, coord.steps + 1, char, coord.path.dup.add(coord.to_s))
  end

  def south(coord)
    return nil if coord.y == @matrix.length - 1

    new_y = coord.y + 1
    char = @matrix[new_y][coord.x]
    return nil if char == '#'

    Coord.new(coord.x, new_y, coord.steps + 1, char, coord.path.dup.add(coord.to_s))
  end

  def east(coord)
    return nil if coord.x == @matrix[0].length - 1

    new_x = coord.x + 1
    char = @matrix[coord.y][new_x]
    return nil if char == '#'

    Coord.new(new_x, coord.y, coord.steps + 1, char, coord.path.dup.add(coord.to_s))
  end

  def west(coord)
    return nil if coord.x == 0

    new_x = coord.x - 1
    char = @matrix[coord.y][new_x]
    return nil if char == '#'

    Coord.new(new_x, coord.y, coord.steps + 1, char, coord.path.dup.add(coord.to_s))
  end
end

s = Solver.new(lines)
puts s.graph_traverse

# 4926 incorrect
# 5974 too low
# 2010 too low
# 6094 incorrect

# 6298 popcorn brute force
# expects 6598
