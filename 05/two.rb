require 'pathname'
require 'pry-nav'

class Mapping
  attr_accessor :src, :dest, :ranges

  def initialize(src, dest)
    @src, @dest = [src, dest].map(&:to_sym)
    @ranges = []
  end

  def add_range(dest_start, src_start, length)
    offset = dest_start - src_start
    @ranges << [
      (src_start...(src_start + length)),
      offset
    ]
  end

  def map(number)
    if (range = @ranges.find { |s, _| s.cover?(number) })
      src_range, dest_range = range
      dest_range.begin + (number - src_range.begin)
    else
      number
    end
  end

  def fill_gaps
    @ranges.sort! { |a, b| a[0].begin <=> b[0].begin }

    gaps = []
    gaps << (-Float::INFINITY...ranges[0][0].begin)
    gaps << (ranges[-1][0].end...Float::INFINITY)

    @ranges.length.times do |i|
      if @ranges[i + 1] && @ranges[i + 1][0].begin > @ranges[i][0].end
        gap = @ranges[i][0].end...@ranges[i + 1][0].begin
        gaps << gap
      end
    end

    gaps.map! { |range| [range, 0]}

    @ranges += gaps
  end
end

almanac = []
seeds = []

File.open(File.join(__dir__, 'input.txt'), 'r') do |file|
  line = file.readline.chomp
  seeds = line[7..].split(/\s+/).map(&:to_i)
  file.readline

  until file.eof?
    line = file.readline.chomp
    _, source, destination = /(\w+)-to-(\w+)/i.match(line).to_a

    mapping = Mapping.new(source, destination)
    almanac << mapping

    loop do
      line = file.readline.chomp
      break if /\A\s*\z/.match?(line) || file.eof?

      dest_start, src_start, length = line.split(/\s+/).map(&:to_i)
      mapping.add_range(dest_start, src_start, length)
    end
    mapping.fill_gaps
  end
end

seed_ranges = seeds.each_slice(2).map { |slice| slice[0]...(slice[0] + slice[1]) }

def split_and_shift_range(source_range, check_range, shift)
  overlap_start = [source_range.begin, check_range.begin].max
  overlap_end = [source_range.end, check_range.end].min

  return [] if overlap_start >= overlap_end

  overlap = (overlap_start...overlap_end)
  ((overlap.begin + shift)...(overlap.end + shift))
end

def traverse(ranges, mapping)
  # for each range
  # source_range
  # ranges.each do |range|
  #   if(range.overlaps(source_range))
  #     define overlap and shift
  new_ranges = []
  ranges.each do |source_range|

    mapping.ranges.each do |map_range|
      # Map class has an array of ranges
      # each range in ranges:
      # source_range, offset
      source_map, offset = map_range
      split_and_shift = split_and_shift_range(source_range, source_map, offset)
      new_ranges << split_and_shift
    end

  end
  new_ranges.flatten
end

soil_destination_ranges = almanac.reduce(seed_ranges) do |ranges, map|
  traverse(ranges, map)
end

res = soil_destination_ranges.min { |a, b| a.begin <=> b.begin }.begin

puts res

# expect 79004094
