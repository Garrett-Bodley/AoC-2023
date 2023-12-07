# frozen_string_literal: true

require 'pathname'
require 'pry-nav'

arg = ARGV.shift

case arg
when 'input'
  FILE_PATH = Pathname.new(File.expand_path('input.txt'))
  LOG_PATH = FILE_PATH.parent.join('log_input2.txt')
when 'test'
  FILE_PATH = Pathname.new(File.expand_path('test.txt'))
  LOG_PATH = FILE_PATH.parent.join('log_test2.txt')
else
  FILE_PATH = Pathname.new(File.expand_path('input.txt'))
  LOG_PATH = FILE_PATH.parent.join('log_input2.txt')
end

# Represents a hand of cards
class Hand
  attr_reader :cards, :bid, :strength, :joker_count

  @all = []
  @cardmap = {
    'J' => 0,
    '2' => 1,
    '3' => 2,
    '4' => 3,
    '5' => 4,
    '6' => 5,
    '7' => 6,
    '8' => 7,
    '9' => 8,
    'T' => 9,
    'Q' => 10,
    'K' => 11,
    'A' => 12
  }

  def initialize(cards, bid)
    @cards = cards
    @bid = bid.to_i
    self.class.all << self
    score_cards
  end

  # rubocop plz shut up
  def score_cards # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
    map = {}
    map['J'] = 0
    @cards.each_char do |card|
      if map[card]
        map[card] += 1
      else
        map[card] = 1
      end
    end

    sorted = map.to_a.sort { |a, b| b[1] - a[1] }.reject { |card| card[0] == 'J' }
    @joker_count = map['J']

    value = sorted.empty? ? @joker_count : sorted[0][1] + @joker_count

    case value
    when 5
      @strength = 7
    when 4
      @strength = 6
    when 3
      @strength = sorted[1][1] == 2 ? 5 : 4
    when 2
      @strength = sorted[1][1] == 2 ? 3 : 2
    when 1
      @strength = 1
    end
  end

  def self.all # rubocop:disable Style/TrivialAccessors
    @all
  end

  def self.sort_hands # rubocop:disable Metrics/MethodLength
    @all.sort! do |a, b|
      comparison = a.strength - b.strength

      if comparison.zero?
        5.times do |i|
          a_strength = @cardmap[a.cards[i]]
          b_strength = @cardmap[b.cards[i]]
          next if a_strength == b_strength

          comparison = a_strength - b_strength
          break
        end
      end

      comparison
    end
  end
end

logfile = File.open(LOG_PATH, File::CREAT | File::RDWR | File::TRUNC )

File.open(FILE_PATH, File::RDONLY).readlines(chomp: true).each do |line|
  hand, bid = line.split(' ')
  Hand.new(hand, bid)
end

Hand.sort_hands

winnings = Hand.all.each_with_index.reduce(0) do |accum, (hand, index)|
  accum + (hand.bid * (index + 1))
end

puts winnings

Hand.all.each do |hand|
  logfile.puts "Cards: #{hand.cards}, Bid: #{hand.bid}, Strength: #{hand.strength}"
end

# expect 244848487
