# This script was written for the advent of code 2024 day 1.
# https://adventofcode.com/2024/day/1

require 'uri'
require 'net/http'

class Solver
  def initialize(day, year = 2024)
    @day = day
    @year = year
  end

  def fetch_input
    input_directory = 'input'
    unless Dir.exist? input_directory
      Dir.mkdir input_directory
    end
    
    input_file_name = "#{@year}-#{@day}-input.txt"
    input_file_path = File.join input_directory, input_file_name
    
    if File.exist? input_file_path
      input_file = File.open input_file_path
      @input = input_file.read.chomp
      input_file.close
      return
    end
    
    auth_filename = 'cookie.txt'
    unless File.exist? auth_filename
      abort('"cookie.txt" is required to get the puzzle input for your account.')
    end

    cookie_file = File.open auth_filename

    uri = URI("https://adventofcode.com/#{@year}/day/#{@day}/input")
    cookie_value = cookie_file.read.chomp
    user_agent = 'github.com/naturaln0va/aoc2024 by Ryan Ackermann'
    headers = { 'Cookie' => "session=#{cookie_value}", 'User-Agent' => user_agent }
    
    cookie_file.close

    puts "fetching the puzzle input for day #{@day}..."
    res = Net::HTTP.get_response(uri, headers)

    unless res.is_a? Net::HTTPSuccess
      abort("HTTP Error: #{res.code} - #{res.body}")
    end
    
    @input = res.body
    
    File.write(input_file_path, @input)
  end

  def test_case
    puts "===TEST==="
    first_test_input = "3   4
    4   3
    2   5
    1   3
    3   9
    3   3"
    first_answer = solve_first(first_test_input)
    puts "1st answer: #{first_answer}"
    second_test_input = first_test_input
    second_answer = solve_second(second_test_input)
    puts "2nd answer: #{second_answer}"
  end

  def decipher
    fetch_input
    puts "===PUZZLE==="
    first_answer = solve_first(@input)
    puts "1st answer: #{first_answer}"
    second_answer = solve_second(@input)
    puts "2nd answer: #{second_answer}"
  end

  def solve_first(input)
    answer = 0
    lines = input.lines.map(&:strip)
    cols = lines.map { |l| l.split('   ') }.transpose.map { |t| t.map(&:to_i).sort }
    diffs = []
    count = lines.length - 1
    (0..count).each do |i|
      diffs << (cols.last[i] - cols.first[i]).abs
    end
    answer = diffs.sum
    answer
  end

  def solve_second(input)
    answer = 0
    lines = input.lines.map(&:strip)
    cols = lines.map { |l| l.split('   ') }.transpose.map { |t| t.map(&:to_i).sort }
    diffs = []
    count = lines.length - 1
    tally = cols.last.tally
    (0..count).each do |i|
      num = cols.first[i]
      diffs << num * tally.fetch(num, 0)
    end
    answer = diffs.sum
    answer
  end
end

s = Solver.new(day = 1)
s.test_case
puts ""
s.decipher
