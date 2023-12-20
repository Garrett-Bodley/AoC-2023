# frozen_string_literal: true

require 'pathname'
require 'pry-nav'
require 'ostruct'

arg = ARGV.shift

case arg
when /input|input.txt/
  FILE_PATH = Pathname.new(File.expand_path('input.txt'))
when /test|test.txt/
  FILE_PATH = Pathname.new(File.expand_path('test.txt'))
else
  raise ArgumentError, "Expects 'input' or 'test' as command line argument"
end

filters, _parts = File.open(FILE_PATH, File::RDONLY).read.split("\n\n").map { |chunk| chunk.split("\n") }

# Solves Day 19 Challenge
class Solver
  attr_accessor :filters, :parts

  # Represents the range of valid parts per applied rule
  Part = Class.new(OpenStruct) do

    def parse_condition(string)
      attribute = string[0]
      operator = string[1]
      val = string.match(/\d+/)[0].to_i
      [attribute, operator, val]
    end

    def eval(rule) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      # ex: a<2006
      return Filter.dispatch(rule[0], self) if rule.length == 1

      condition, dest = rule
      attribute, operator, val = parse_condition(condition)
      case operator
      when '<'
        # Break range up
        if self[attribute].begin < val
          # break range into two parts
          new_part = self.dup
          # new part becomes (old_range_begin...val)
          new_part[attribute] = self[attribute].begin...val

          # existing part's range becomes (val...old_range_end)
          # old_range >= val
          self[attribute] = val...self[attribute].end

          Filter.dispatch(dest, new_part)
        end
      when '>'
        if self[attribute].end - 1 > val
          # Create a new part
          new_part = self.dup
          # new part's range is (val + 1...old_range_end)
          new_part[attribute] = val + 1...self[attribute].end

          # existing part's range becomes (old_range_begin...val + 1)
          # old_range <= val
          self[attribute] = self[attribute].begin...val + 1

          Filter.dispatch(dest, new_part)
        end
      end
    end
  end

  # Handles logic for filtering parts
  class Filter
    attr_accessor :name, :rules, :string

    @@all = []
    @@lookup = {}
    @@accepted = []
    @@rejected = []

    def initialize(string)
      @string = string
      parse_filter_string
      @@all << self
      @@lookup[@name] = self
    end

    def parse_filter_string
      chunks = @string.split(/{|}|,/)
      @name = chunks.shift
      @rules = chunks.map { |chunk| chunk.split(':') }
    end

    def self.dispatch(name, part)
      case name
      when 'A'
        @@accepted << part
      when 'R'
        @@rejected << part
      else
        @@lookup[name].judge(part)
      end
    end

    # Parts now mutate themselves and dispatch child parts when #eval is called
    def judge(part)
      @rules.each do |rule|
        part.eval(rule)
      end
    end

    def self.all
      @@all
    end

    def self.lookup
      @@lookup
    end

    def self.accepted
      @@accepted
    end

    def self.rejected
      @@rejected
    end
  end

  def initialize(filters)
    @filters = []
    @part = Part.new(x: 1...4001, m: 1...4001, a: 1...4001, s: 1...4001)
    parse_filters(filters)
  end

  # lol nope
  def brute_force_parts
    (1..1000).each do |x|
      (1..1000).each do |m|
        (1..1000).each do |a|
          (1..1000).each do |s|
            init = { x: x, m: m, a: a, s: s }
            @parts << Part.new(init)
          end
        end
      end
    end
  end

  def solve
    Filter.dispatch('in', @part)
  end

  def parse_parts(parts)
    parts.each do |string|
      parsed = string.gsub(/{|}/, '').split(',').map { |el| el.split('=') }
      new_part = Part.new
      parsed.each do |attribute, val|
        new_part[attribute] = val.to_i
      end
      @parts << new_part
    end
  end

  def parse_filters(filters)
    filters.each do |filter_string|
      @filters << Filter.new(filter_string)
    end
  end

  def checksum
    Filter.accepted.reduce(0) do |sum, part|
      sum + part.to_h.values.reduce(1) { |part_product, val| part_product * (val.end - val.begin) }
    end
  end
end

s = Solver.new(filters)
s.solve
puts s.checksum

# expects 117954800808317
