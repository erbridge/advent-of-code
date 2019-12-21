# frozen_string_literal: true

require 'set'

# rules:
# - 6-digits
# - inside input range
# - at least 2 adjacent digits are equal
# - ltr, digits never decrease
# - there are no more than 2 digits in any sequence of identical digits

input_range_values = IO.readlines('./input.txt', '-').map do |value|
  value.delete_suffix('-').to_i
end

input_range = input_range_values.first..input_range_values.last

passwords = input_range.select do |password|
  matching_digits = Set.new
  last_last_digit = 0
  last_digit = 0

  non_decreasing = password.to_s.split('').all? do |digit|
    matching_digits.add(digit) if digit == last_digit && digit != last_last_digit

    if digit == last_digit && digit == last_last_digit
      matching_digits.delete(digit)
    end

    next false if last_digit.to_i > digit.to_i

    last_last_digit = last_digit
    last_digit = digit

    true
  end

  non_decreasing && matching_digits.any?
end

puts passwords.count
