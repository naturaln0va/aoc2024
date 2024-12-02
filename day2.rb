# This script was written for the advent of code 2024 day 2.
# https://adventofcode.com/2024/day/2

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
    first_test_input = "7 6 4 2 1
    1 2 7 8 9
    9 7 6 2 1
    1 3 2 4 5
    8 6 4 4 1
    1 3 6 7 9"
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
    reports = input.lines.map { |i| i.strip.split.map(&:to_i) }
    safe = []
    reports.each do |report|
      safe << report if is_report_valid?(report)
    end
    answer = safe.length
    answer
  end

  def solve_second(input)
    answer = 0
    reports = input.lines.map { |i| i.strip.split.map(&:to_i) }
    safe = []
    reports.each do |report|
      if is_report_valid?(report)
        safe << report
      else
        report.each_index do |i|
          new_report = report.dup
          new_report.delete_at(i)
          if is_report_valid?(new_report)
            safe << report
            break
          end
        end
      end
    end
    answer = safe.length
    answer
  end
  
  def is_report_valid?(report)
    pdir = nil
    final = report.length - 1
    report.each_with_index do |num, idx|
      if idx == final
        return true
      end
      b = report[idx + 1]
      diff = b - num
      dir = diff > 0
      unless diff.abs.between?(1,3)
        break
      end
      if pdir.nil?
        pdir = dir
      else
        if pdir != dir
          break
        end
      end
    end
    return false
  end
end

s = Solver.new(day = 2)
s.test_case
puts ""
s.decipher
