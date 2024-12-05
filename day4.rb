# This script was written for the advent of code 2024 day 4.
# https://adventofcode.com/2024/day/4

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
    first_test_input = "MMMSXXMASM
    MSAMXMSMSA
    AMXSXMAAMM
    MSAMASMSMX
    XMASAMXAMM
    XXAMMXXAMA
    SMSMSASXSS
    SAXAMASAAA
    MAMMMXMMMM
    MXMXAXMASX"
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
    width = lines[0].length
    height = lines.length
    lookup = lines.join
    # Read in 8 directions for each position
    # Only start on a "X" and "S" since we are looking for "XMAS" and "SAMX"
    start_chars = ["X", "S"]
    lookup.each_char.with_index do |char, index|
      next unless start_chars.include? char
      # puts "\n#{char} at #{index}"
      case char
      when "X"
        answer += search("XMAS", index, lookup, width, height)
      when "S"
        answer += search("SAMX", index, lookup, width, height)
      end
    end
    answer
  end
  
  def coords(index, width, height)
    row = index % width
    col = index / height
    return row, col
  end
  
  def index(row, col, width)
    return col * width + row
  end
  
  def search(target, index, lookup, width, height)
    # Read forward for the target
    row, col = coords(index, width, height)
    total = 0
    if check_east(target, index, lookup, width, height)
      total += 1
    end
    if check_south(target, index, lookup, width, height)
      total += 1
    end
    if check_north_east(target, index, lookup, width, height)
      total += 1
    end
    if check_south_east(target, index, lookup, width, height)
      total += 1
    end
    # puts "[#{row}, #{col}] = #{total}" if total > 0
    total
  end
  
  def check_east(target, index, lookup, width, height)
    row, col = coords(index, width, height)
    adjusted_target_length = target.length - 1
    return false if (row + adjusted_target_length) > width - 1
    # puts "looking east"
    word = ""
    (0..3).each { |i| word << lookup[index + i] }
    return word == target
  end
  
  def check_south(target, index, lookup, width, height)
    row, col = coords(index, width, height)
    adjusted_target_length = target.length - 1
    return false if (col + adjusted_target_length) > height - 1
    # puts "looking south"
    word = ""
    (0..3).each do |i|
      new_index = index(row, col + i, width)
      word << lookup[new_index]
    end
    return word == target
  end
  
  def check_north_east(target, index, lookup, width, height)
    row, col = coords(index, width, height)
    adjusted_target_length = target.length - 1
    return false if (row + adjusted_target_length) > width - 1 || (col - adjusted_target_length) < 0
    # puts "looking north east"
    word = ""
    (0..3).each do |i|
      new_index = index(row + i, col - i, width)
      word << lookup[new_index]
    end
    return word == target
  end
  
  def check_south_east(target, index, lookup, width, height)
    row, col = coords(index, width, height)
    adjusted_target_length = target.length - 1
    return false if (row + adjusted_target_length) > width - 1 || (col + adjusted_target_length) > height - 1
    # puts "looking south east"
    word = ""
    (0..3).each do |i|
      new_index = index(row + i, col + i, width)
      word << lookup[new_index]
    end
    return word == target
  end
  
  def solve_second(input)
    answer = 0
    lines = input.lines.map(&:strip)
    numbers = input.split().map { |s| s.to_i }
    answer
  end
end

s = Solver.new(day = 4)
s.test_case
puts ""
s.decipher
