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

filters, parts = File.open(FILE_PATH, File::RDONLY).read.split("\n\n").map{ |chunk| chunk.split("\n") }

# Handles logic for filtering parts
class Filter
  attr_accessor :name, :chunks, :rules, :string

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
    @rules = chunks.map{ |chunk| chunk.split(':') }
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

  def judge(part)
    @rules.each do |rule|
      if rule.length == 1
        dest = rule[0]
        Filter.dispatch(dest, part)
        break
      else
        rule, dest = rule
        if part.eval(rule)
          Filter.dispatch(dest, part)
          break
        end
      end
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

# Solves Day 19 Challenge
class Solver
  attr_accessor :filters, :parts

  Part = Struct.new(*%i[x m a s]) do
    def eval(rule)
      # ex: a<2006
      attribute, operator, val = parse_rule(rule)
      case operator
      when '<'
        send(attribute.to_s) < val
      when '>'
        send(attribute.to_s) > val
      end
    end

    def parse_rule(string)
      attribute = string[0]
      operator = string[1]
      val = string.match(/\d+/)[0].to_i
      [attribute, operator, val]
    end
  end

  def initialize(filters, parts)
    @filters = []
    @parts = []
    parse_parts(parts)
    parse_filters(filters)
  end

  def solve
    parts.each do |part|
      Filter.dispatch('in', part)
    end
  end

  def parse_parts(parts)
    parts.each do |string|
      parsed = string.gsub(/{|}/, '').split(',').map { |el| el.split('=') }
      new_part = Part.new
      parsed.each do |attribute, val|
        new_part.send("#{attribute}=", val.to_i)
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
      sum + part.to_a.reduce(0) { |part_sum, val| part_sum + val }
    end
  end
end

s = Solver.new(filters, parts)
s.solve
puts s.checksum

# expects 383682
