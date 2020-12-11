module.exports = {
  findMySeatId(lines) {
    const seatIds = lines.map(module.exports.calculateSeatId);

    seatIds.sort((a, b) => (a < b ? -1 : a === b ? 0 : 1));

    let lastSeatId = seatIds[0] - 1;

    for (const seatId of seatIds) {
      if (seatId - lastSeatId !== 1) {
        return lastSeatId + 1;
      }

      lastSeatId = seatId;
    }
  },

  findHighestSeatId(lines) {
    const seatIds = lines.map(module.exports.calculateSeatId);

    seatIds.sort((a, b) => (a < b ? 1 : a === b ? 0 : -1));

    return seatIds[0];
  },

  calculateSeatId(line) {
    const { frontBack, leftRight } = module.exports.splitIdentifier(line);

    const row = module.exports.calculateRow(frontBack);
    const column = module.exports.calculateColumn(leftRight);

    return row * 8 + column;
  },

  calculateRow(identifier) {
    const sections = identifier.split("");

    let max = 127;
    let min = 0;

    for (const section of sections) {
      const midPoint = min + (max + 1 - min) / 2;

      if (section === "F") {
        max = midPoint - 1;
      } else if (section === "B") {
        min = midPoint;
      }
    }

    if (max !== min) {
      throw new Error();
    }

    return max;
  },

  calculateColumn(identifier) {
    const sections = identifier.split("");

    let max = 7;
    let min = 0;

    for (const section of sections) {
      const midPoint = min + (max + 1 - min) / 2;

      if (section === "L") {
        max = midPoint - 1;
      } else if (section === "R") {
        min = midPoint;
      }
    }

    if (max !== min) {
      throw new Error();
    }

    return max;
  },

  splitIdentifier(line) {
    const frontBack = line.slice(0, 7);
    const leftRight = line.slice(7);

    return { frontBack, leftRight };
  },
};

if (require.main === module) {
  const readLinesFromFile = require("../utils/readLinesFromFile");

  const lines = readLinesFromFile(`${__dirname}/input.txt`);

  const highestSeatId = module.exports.findHighestSeatId(lines);
  const mySeatId = module.exports.findMySeatId(lines);

  console.log(highestSeatId);
  console.log(mySeatId);
}
