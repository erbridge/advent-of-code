const { calculateSeatId } = require(".");

describe("calculateSeatId", () => {
  it.each([
    ["FBFBBFFRLR", 357],
    ["BFFFBBFRRR", 567],
    ["FFFBBBFRRR", 119],
    ["BBFFBBFRLL", 820],
  ])("calculates the correct seat ID from %s", (line, seatId) => {
    expect(calculateSeatId(line)).toEqual(seatId);
  });
});
