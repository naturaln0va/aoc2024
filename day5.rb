# This script was written for the advent of code 2024 day 5.
# https://adventofcode.com/2024/day/5

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
    first_test_input = "47|53
    97|13
    97|61
    97|47
    75|29
    61|13
    75|53
    29|13
    97|29
    53|29
    61|53
    97|53
    61|29
    47|13
    75|47
    97|75
    47|61
    75|61
    47|29
    75|13
    53|13
    
    75,47,61,53,29
    97,61,53,29,13
    75,29,13
    75,97,47,61,53
    61,13,29
    97,13,75,29,47"
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
    parts = input.lines.map(&:strip).join("\n").split("\n\n")
    rules = parts.first.lines.map { _1.strip.split("|") }
    values = []
    updates = parts.last.lines.map(&:strip)
    updates.each do |line|
      comps = line.split(",")
      if validate(comps, rules)
        values << comps[comps.length / 2].to_i
      end
    end
    answer = values.sum
    answer
  end
  
  def validate(comps, rules)
    rules.each do |rule|
      first_rule_index = comps.index(rule.first)
      next if first_rule_index.nil?
      second_rule_index = comps.index(rule.last)
      next if second_rule_index.nil?
      return false if first_rule_index > second_rule_index
    end
    true
  end

  def solve_second(input)
    answer = 0
    lines = input.lines.map(&:strip)
    numbers = input.split().map { |s| s.to_i }
    answer
  end
end

s = Solver.new(day = 5)
s.test_case
puts ""
s.decipher
