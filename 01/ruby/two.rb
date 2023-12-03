require 'pry-nav'

base_path = Pathname.new(__dir__)
input_path = base_path.parent.join('input.txt')
input = File.open(input_path, File::RDONLY)
lines = input.readlines(chomp: true)

sum = 0

log_path = base_path.join('rlog2.txt')
log_file = File.open(log_path, File::CREAT | File::RDWR | File::TRUNC)

wordmap = {
  'one' => 1,
  'two' => 2,
  'three' => 3,
  'four' => 4,
  'five' => 5,
  'six' => 6,
  'seven' => 7,
  'eight' => 8,
  'nine' => 9,
  'zero' => 0
}

pattern = Regexp.union(*wordmap.keys, /\d/)

lines.each do |line|
  first = line.match(pattern).to_s
  first = wordmap[first] if wordmap.key?(first)

  last = ''
  line.reverse.each_char do |char|
    last.prepend char
    break if last.match(pattern)
  end
  last = last.match(pattern).to_s
  last = wordmap[last] if wordmap.key?(last)

  val = [first, last].join.to_i
  sum += val
  log_file.puts "#{val}    #{line}"
end

log_file.puts sum
puts sum

# expect 54985
