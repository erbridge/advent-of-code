# frozen_string_literal: true

def add(memory, parameter_a, parameter_b)
  memory[parameter_a] + memory[parameter_b]
end

def multiply(memory, parameter_a, parameter_b)
  memory[parameter_a] * memory[parameter_b]
end

def run(program)
  program.each_slice(4) do |instruction|
    case instruction[0]
    when 1
      program[instruction[3]] = add(program, instruction[1], instruction[2])
    when 2
      program[instruction[3]] = multiply(program, instruction[1], instruction[2])
    when 99 then break
    else raise "Unexpected opcode #{instruction[0]}"
    end
  end
end

program = IO.readlines('./input.txt', ',').map do |digit|
  digit.delete_suffix(',').to_i
end

program[1] = 12
program[2] = 2

run(program)

puts program[0]
