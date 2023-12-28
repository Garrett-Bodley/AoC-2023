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

  def find_cycle(gate_name, high, cycle_count)
    reset_gates
    press_count = 0
    res = []
    loop do
      press_count += 1
      packets = [Packet.new('broadcaster', 'button', false)]
      until packets.empty?
        cur = packets.shift
        res << [press_count, cur] if cur.from == gate_name && cur.high == high
        return res if res.length == cycle_count
        next unless @gates[cur.to]

        new_packets = @gates[cur.to].receive(cur)
        packets += new_packets
      end
    end
  end

  def reset_gates
    @gates.values do |gate|
      case gate.class
      when Nand
        gate.state.each_key { |key| gate.state[key] = false }
      when FlipFlop
        gate.state = false
      when Broadcaster
        next
      end
    end
  end

  def cycle_log
    # rx low when all bq inputs high

    # bq inputs:
    # vg, kp, gc, tx
    vg_cycles = find_cycle('vg', true, 5)
    kp_cycles = find_cycle('kp', true, 5)
    gc_cycles = find_cycle('gc', true, 5)
    tx_cycles = find_cycle('tx', true, 5)

    [vg_cycles, kp_cycles, gc_cycles, tx_cycles]
  end

  def solve
    cycles = cycle_log
    periods = cycles.map { |period| period[1][0] - period[0][0] }
    binding.pry

    periods.reduce(1) { |mult, period| lcm(mult, period) }

    # idk why you can ignore the lead in before the cycle
    # vg_period = 4027
    # vg_lead_in = 0

    # kp_period = 3929
    # kp_lead_in = 776

    # gc_period = 4001
    # gc_lead_in = 4433

    # tx_period = 3769
    # tx_lead_in = 5234

    # inputs = [
    #   [vg_period, vg_lead_in],
    #   [kp_period, kp_lead_in],
    #   [gc_period, gc_lead_in],
    #   [tx_period, tx_lead_in]
    # ]

    # max_period = [vg_period, kp_period, gc_period, tx_period].max
    # t = [vg_lead_in, kp_lead_in, gc_lead_in, tx_lead_in].max

    # loop do
    #   return t if inputs.all? { |period, lead_in| (t - lead_in) % period == 0 }

    #   t += max_period
    # end

  end

  def gcd(a, b)
    return a if b.zero?

    gcd(b, a % b)
  end

  def lcm(a, b)
    (a * b) / gcd(a, b)
  end


  def checksum
    @high_count * (@packet_count - @high_count)
  end

end

s = Solver.new(lines, 1000)
puts s.solve

# expects 238593356738827

# rx low when all bq inputs high

# bq inputs:
# vg, kp, gc, tx

# vg inputs:
# lx

# lx inputs:

# rubocop:enable Style/ClassVars
