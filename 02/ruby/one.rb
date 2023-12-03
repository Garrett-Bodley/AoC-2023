require 'pathname'
require 'pry-nav'

# https://adventofcode.com/2023/day/2

base_path = Pathname.new(File.expand_path(__dir__))
input_path = base_path.parent.join('input.txt')
log_path = base_path.join('rlog1.txt')

input_file = File.open(input_path, File::RDONLY)
log_file = File.open(log_path, File::CREAT | File::RDWR | File::TRUNC)

lines = input_file.readlines(chomp: true)
sum = 0

lines.each do |line|
  hash = {}
  valid = false
  tokens = line.split(/ ?[:,;] ?/)
  id = tokens[0].match(/\d+/)[0].to_i

  tokens.slice(1..-1).each do |token|
    count, color = token.split(/ /)
    hash[color] = count.to_i unless hash.key?(color)
    hash[color] = count.to_i if count.to_i > hash[color]
  end

  valid = true if hash['red'] <= 12 && hash['green'] <= 13 && hash['blue'] <= 14
  sum += id if valid

  log_file.puts("Id: #{id},  valid: #{valid}, sum: #{sum}, red: #{hash['red']}, green: #{hash['green']}, blue:  #{hash['blue']}")
end

puts sum

# expect 3059
