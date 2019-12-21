# frozen_string_literal: true

# rules:
# - 6-digits
# - inside input range
# - at least 2 adjacent digits are equal
# - ltr, digits never decrease

input_range_values = IO.readlines('./input.txt', '-').map do |value|
  value.delete_suffix('-').to_i
end

input_range = input_range_values.first..input_range_values.last

passwords = input_range.select do |password|
  some_digits_match = false
  last_digit = 0

  non_decreasing = password.to_s.split('').all? do |digit|
    some_digits_match = true if digit == last_digit

    next false if last_digit.to_i > digit.to_i

    last_digit = digit

    true
  end

  some_digits_match && non_decreasing
end

puts passwords.count
