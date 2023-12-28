# rubocop:disable Style/NumericPredicate
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

# Solves Day 12 Part 2
class Solver
  Kase = Struct.new(:string, :groups)

  def initialize(input)
    @input = input
    @kases = parse_input(@input)
    @memo = {}
  end

  def parse_input(input)
    input.map do |line|
      string, nums = line.split(' ')
      compressed = string.gsub(/\.+/, '.')
      unfolded_str = ([compressed] * 5).join('?')
      groups = nums.split(',').map(&:to_i)
      unfolded_groups = ([groups] * 5).flatten
      Kase.new(unfolded_str, unfolded_groups)
    end
  end

  # rubocop very mad w/this function
  def permutations(string, groups, str_idx, grp_idx, grp_sz) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    return @memo[[str_idx, grp_idx, grp_sz]] unless @memo[[str_idx, grp_idx, grp_sz]].nil?

    if str_idx == string.length
      if (grp_idx == groups.length && grp_sz == 0) || (grp_idx == groups.length - 1 && grp_sz == groups[-1]) # rubocop:disable Style/NumericPredicate, Style/GuardClause
        return 1
      else
        return 0
      end
    end

    res = 0

    # If '.'
    if string[str_idx].match?(/[.?]/)
      if grp_sz == 0
        res += permutations(string, groups, str_idx + 1, grp_idx, 0)
      else
        return 0 if grp_idx == groups.length

        res += permutations(string, groups, str_idx + 1, grp_idx + 1, 0) if grp_sz == groups[grp_idx]
      end
    end

    # If '?'
    res += permutations(string, groups, str_idx + 1, grp_idx, grp_sz + 1) if string[str_idx].match?(/[?#]/)

    @memo[[str_idx, grp_idx, grp_sz]] = res
    res
  end

  def solve
    @kases.reduce(0) do |sum, kase|
      # binding.pry
      @memo.clear
      sum + permutations(kase.string, kase.groups, 0, 0, 0)
    end
  end
end

s = Solver.new(lines)
puts s.solve

# expects 10153896718999

# rubocop:enable Style/NumericPredicate
