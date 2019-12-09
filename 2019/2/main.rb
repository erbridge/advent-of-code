# frozen_string_literal: true

def add(memory, parameter_a, parameter_b)
  memory[parameter_a] + memory[parameter_b]
end

def multiply(memory, parameter_a, parameter_b)
  memory[parameter_a] * memory[parameter_b]
end

def run(memory)
  memory.each_slice(4) do |instruction|
    case instruction[0]
    when 1
      memory[instruction[3]] = add(memory, instruction[1], instruction[2])
    when 2
      memory[instruction[3]] = multiply(memory, instruction[1], instruction[2])
    when 99 then break
    else raise "Unexpected opcode #{instruction[0]}"
    end
  end
end

program = IO.readlines('./input.txt', ',').map do |digit|
  digit.delete_suffix(',').to_i
end

(0..9999).each do |input|
  noun = input / 100
  verb = input - (noun * 100)

  memory = program.dup

  memory[1] = noun
  memory[2] = verb

  run(memory)

  if memory[0] == 19_690_720
    puts input
    break
  end
end
