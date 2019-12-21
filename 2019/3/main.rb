# frozen_string_literal: true

def run_wire(wire, instruction)
  direction = instruction[0]
  length = instruction[1..].to_i

  case direction
  when 'R' then length.times { wire.push([wire.last[0] + 1, wire.last[1]]) }
  when 'L' then length.times { wire.push([wire.last[0] - 1, wire.last[1]]) }
  when 'U' then length.times { wire.push([wire.last[0], wire.last[1] + 1]) }
  when 'D' then length.times { wire.push([wire.last[0], wire.last[1] - 1]) }
  end
end

def distances_from_origin(points)
  points.map { |point| point[0].abs + point[1].abs }
end

def steps_from_origin(wires, points)
  points.map do |point|
    wires[0].index(point) + 1 + wires[1].index(point) + 1
  end
end

wires = IO.readlines('./input.txt').map do |instructions|
  next if instructions.empty?

  wire = [[0, 0]]

  instructions.split(',').each { |instruction| run_wire(wire, instruction) }

  wire.shift
  wire
end

crossing_points = wires[0] & wires[1]

puts steps_from_origin(wires, crossing_points).min
