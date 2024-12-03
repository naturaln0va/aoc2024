# This script was written for the advent of code 2024 day 3.
# https://adventofcode.com/2024/day/3

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
    first_test_input = "xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))"
    first_answer = solve_first(first_test_input)
    puts "1st answer: #{first_answer}"
    second_test_input = "xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))"
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
    re = /mul\([0-9]{1,3},[0-9]{1,3}\)/
    matches = input.strip.scan(re)
    values = matches.map { |m| calc(m) }
    answer = values.sum
    answer
  end

  def solve_second(input)
    answer = 0
    can_calc = true
    re = /mul\([0-9]{1,3},[0-9]{1,3}\)|do\(\)|don't\(\)/
    matches = input.strip.scan(re)
    matches.each do |m|
      case m
      when "do()"
        can_calc = true
      when "don't()"
        can_calc = false
      else
        next unless can_calc
        answer += calc(m)
      end
    end
    answer
  end
  
  private
  
  def calc(exp)
    re = /[0-9]{1,3}/
    values = exp.scan(re).map(&:to_i)
    return 0 if values.length != 2
    values[0] * values[1]
  end
end

s = Solver.new(day = 3)
s.test_case
puts ""
s.decipher
