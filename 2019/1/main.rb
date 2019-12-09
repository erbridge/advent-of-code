# frozen_string_literal: true

module_masses = IO.readlines('./input.txt')

fuel_by_module = module_masses.map do |mass|
  (mass.to_i / 3) - 2 unless mass.empty?
end

total_fuel = fuel_by_module.sum

puts total_fuel
