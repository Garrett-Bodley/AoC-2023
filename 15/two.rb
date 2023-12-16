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

data = File.open(FILE_PATH, File::RDONLY).readlines(chomp: true)[0].split(',')

# Idk if 'LinearHash' is the right term but it reminded me an LFSR (Linear Feedback Shift Register) so I called it that
class LinearHash
  def initialize
    @memo = 0
  end

  def hash(char)
    raise ArgumentError, 'Expects string input' unless char.instance_of?(String)
    raise ArgumentError, 'Expects single char input' unless char.length == 1

    @memo += char.ord
    @memo *= 17
    @memo %= 256
  end

  def hash_str(str)
    raise ArgumentError, 'Expects string input' unless str.instance_of?(String)

    reset
    str.split('').each { |char| hash(char) }
    @memo
  end

  def reset
    @memo = 0
  end
end

# Hashmap of Lenses
class LensMap
  attr_accessor :buckets

  def initialize(data)
    @buckets = Array.new(256).map{ [] }
    @lh = LinearHash.new
    data.each do |str|
      process(str)
    end
  end

  def process(str)
    if str.include?('=')
      insert(str)
    else
      remove(str)
    end
  end

  def insert(str)
    key = @lh.hash_str(str.split('=').first)
    lens_data = str.split('=')
    match = @buckets[key].find_index { |el| el.match?(lens_data[0]) }
    if match
      @buckets[key][match] = lens_data.join(' ')
    else
      @buckets[key] << lens_data.join(' ')
    end
  end

  def remove(str)
    key = @lh.hash_str(str.split('-').first)
    str.sub!('-', '')
    @buckets[key].reject! do |el|
      el.match?(str)
    end
  end

  def checksum
    sum = 0
    @buckets.each_with_index do |bucket, bucket_idx|
      bucket_val = bucket_idx + 1
      bucket.each_with_index do |lens, lens_idx|
        lens_val = lens_idx + 1
        focal_length = lens.split(' ').last.to_i
        sum += bucket_val * lens_val * focal_length
      end
    end
    sum
  end

end

hash = LensMap.new(data)

puts hash.checksum

# expects 212449
