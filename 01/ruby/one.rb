require 'pathname'
require 'pry-nav'

base_path = Pathname.new(__dir__)
input_path = base_path.parent.join('input.txt')
input = File.open(input_path, File::RDONLY)
lines = input.readlines(chomp: true)

sum = 0

log_path = base_path.join('rlog1.txt')
log_file = File.open(log_path, File::CREAT | File::RDWR | File::TRUNC)

lines.each do |line|
  nums = line.scan(/\d/).to_a
  val = [nums[0], nums[-1]].join.to_i
  sum += val
  log_file.puts "#{val}    #{line}"
end
log_file.puts sum
puts sum
# expect 55130
