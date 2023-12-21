# rubocop:disable Style/ClassVars
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

# Solves Day 20's Problems
class Solver

  # Primitive Gate Class
  class Gate
    attr_accessor :name, :targets, :state

    @@lookup = {}

    def initialize(name, targets)
      @name = name
      @targets = targets
      @@lookup[name] = self
    end

    def sends_to(gate)
      @output << gate
    end

    def self.lookup
      @@lookup
    end

    def notify
      @targets.each do |gate|
        next unless @@lookup[gate]

        @@lookup[gate].wire_in(@name)
      end
    end

    def wire_in(_); end
  end

  # Represents a Signal Packet
  class Packet
    attr_accessor :from, :to, :high

    def initialize(to, from, high)
      @to = to
      @from = from
      @high = high
    end

    def to_s
      "To:#{@to}, From:#{@from}, High: #{@high}"
    end
  end

  # Nand type Gate
  class Nand < Gate
    attr_accessor :state

    def initialize(name, targets)
      super(name, targets)
      @state = {}
    end

    def receive(packet)
      raise ArgumentError unless [true, false].include?(packet.high)

      @state[packet.from] = packet.high
      high = !@state.values.all? { |input| input == true }
      @targets.map { |gate| Packet.new(gate, @name, high) }
    end

    def sends_to(gate)
      @targets << gate
    end

    def wire_in(name)
      @state[name] = false
    end
  end

  # FlipFlop type Gate
  class FlipFlop < Gate
    def initialize(name, targets)
      super(name, targets)
      @state = false
    end

    def receive(packet)
      raise ArgumentError unless [true, false].include?(packet.high)
      return [] if packet.high

      @state = !@state
      @targets.map { |gate| Packet.new(gate, @name, @state) }
    end

    def sends_to(gate)
      @targets << gate
    end
  end

  # Broadcaster type Gate
  class Broadcaster < Gate
    def receive(packet)
      @targets.map { |gate| Packet.new(gate, @name, packet.high) }
    end

    def sends_to(gate)
      @targets << gate
    end
  end

  def initialize(input, push_count)
    @input = parse_input(input)
    @push_count = push_count
    @gates = {}
    @packet_count = 0
    @high_count = 0
    build_gates
  end

  def parse_input(input)
    input.map do |line|
      name, locations = line.split(/\s+->\s+/)
      location_info = locations.split(/, /)
      [name, location_info]
    end
  end

  def build_gates # rubocop:disable Metrics/MethodLength
    @input.each do |name, targets|
      if name == 'broadcaster'
        new_gate = Broadcaster.new(name, targets)
      elsif name.include?('%')
        new_gate = FlipFlop.new(name.sub('%', ''), targets)
      elsif name.include?('&')
        new_gate = Nand.new(name.sub('&', ''), targets)
      else
        binding.pry
      end
      @gates[new_gate.name] = new_gate
    end
    @gates.each_value(&:notify)
  end

  def push_button
    packets = [Packet.new('broadcaster', 'button', false)]
    until packets.empty?
      cur = packets.shift
      @packet_count += 1
      @high_count += 1 if cur.high
      # puts cur.to_s
      next unless @gates[cur.to]

      new_packets = @gates[cur.to].receive(cur)
      packets += new_packets
    end
  end

  def solve
    @push_count.times { push_button }
    checksum
  end

  def checksum
    @high_count * (@packet_count - @high_count)
  end

end

s = Solver.new(lines, 1000)
puts s.solve

# expects 681194780

# rubocop:enable Style/ClassVars
