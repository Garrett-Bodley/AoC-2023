require 'pathname'
require 'pry'

class Mapping
  attr_reader :src, :dest

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
      src_range, offset = range
      number + offset
    else
      number
    end
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
  end
end

locations = seeds.map do |seed|
  almanac.reduce(seed) { |s, mapping| mapping.map(s) }
end

log_path = Pathname.new(File.expand_path('rlog1.txt'))
log_file = File.open(log_path, 'w+')

seeds.each_with_index do |seed, index|
  log_file.puts "seed: #{seed}, location: #{locations[index]}"
end

binding.pry
puts locations.min

# expect 525792406
