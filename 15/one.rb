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

lh = LinearHash.new
puts data.reduce(0) { |sum, str| sum + lh.hash_str(str) }

# expects 510273
