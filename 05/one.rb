# frozen_string_literal: true

require 'pry-nav'
require 'pathname'


input_path = Pathname.new(File.expand_path('./test.txt'))
log_path = input_path.parent.join('test_log.txt')

input_file = File.open(input_path, File::RDONLY)
log_file = File.open(log_path, File::CREAT | File::RDWR | File::TRUNC)

lines = input_file.readlines(chomp: true)
chunks = lines.chunk(&:empty?).map { |_, group| group }.reject { |el| el[0].empty? }

seeds = chunks[0][0].split(' ').slice(1..).map(&:to_i)

class MapRange
  attr_accessor :destination, :source, :range

  def initialize(destination, source, range)
    @destination = destination
    @source = source
    @source_range = (source..source + range - 1)
    @destination_range = (destination..destination + range - 1)
    @range = (0..range - 1)
  end

  def source_cover?(source)
    @source_range.cover?(source)
  end
end

class Map
  attr_accessor :source_type, :dest_type, :hash

  def initialize(source_type, dest_type)
    @source_type = source_type
    @dest_type = dest_type
    @ranges = []
  end

  def add_range(destination, source, range)
    @ranges << MapRange.new(destination, source, range)
  end

  def lookup(source)
    if (match = @ranges.select { |range| range.source_cover?(source) }[0]).nil?
      source
    else
      offset = source - match.source
      match.destination + offset
    end
  end
end

binding.pry

maps = []

chunks[1..].each do |chunk|
  source, destination = chunk[0].split[0].split('-to-')
  map = Map.new(source, destination)
  maps << map
  chunk[1..].each do |line|
    map.add_range(*line.split(' ').map(&:to_i))
  end
end

# seed_to_soil = maps.find { |map| map.source_type == 'seed' && map.dest_type == 'soil' }
# soil_to_fertilizer = maps.find { |map| map.source_type == 'soil' && map.dest_type == 'fertilizer' }
# fertilizer_to_water = maps.find { |map| map.source_type == 'fertilizer' && map.dest_type == 'water' }
# water_to_light = maps.find { |map| map.source_type == 'water' && map.dest_type == 'light' }
# light_to_temperature = maps.find { |map| map.source_type == 'light' && map.dest_type == 'temperature' }
# temperature_to_humidity = maps.find { |map| map.source_type == 'temperature' && map.dest_type == 'humidity' }
# humidity_to_location = maps.find { |map| map.source_type == 'humidity' && map.dest_type == 'location' }

def get_location(seednum, maps)
  maps.reduce(seednum) do |memo, map|
    map.lookup(memo)
  end
end

seed_map = {}

seeds.each do |seed|
  seed_map[seed] = get_location(seed, maps)
end

seed_map.each do |key, val|
  log_file.puts "seed: #{key}, soil: #{val}"
end



puts(seeds.min { |seed| get_location(seed, maps) })

# 43713320689 too high!
# 28965817 too low!
