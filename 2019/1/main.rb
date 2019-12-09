# frozen_string_literal: true

def fuel_needed_for(mass)
  (mass.to_i / 3) - 2
end

def fuel_needed_for_modules_and(fuel_mass)
  fuel = fuel_needed_for(fuel_mass)

  return fuel_mass unless fuel.positive?

  fuel_mass + fuel_needed_for_modules_and(fuel)
end

module_masses = IO.readlines('./input.txt').compact.map(&:to_i)

fuel_needed_for_modules = module_masses.map { |mass| fuel_needed_for(mass) }
fuel_needed_for_modules_and_fuel = fuel_needed_for_modules.map { |fuel_mass| fuel_needed_for_modules_and(fuel_mass) }

total_fuel = fuel_needed_for_modules_and_fuel.sum

puts total_fuel
