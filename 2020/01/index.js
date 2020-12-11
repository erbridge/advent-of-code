module.exports = {
  checkExpenseReport(lines) {
    for (const a of lines) {
      for (const b of lines) {
        if (a + b === 2020) {
          return a * b;
        }
      }
    }
  },

  checkExpenseReportAgain(lines) {
    for (const a of lines) {
      for (const b of lines) {
        for (const c of lines) {
          if (a + b + c === 2020) {
            return a * b * c;
          }
        }
      }
    }
  },
};

if (require.main === module) {
  const readLinesFromFile = require("../utils/readLinesFromFile");

  const lines = readLinesFromFile(`${__dirname}/input.txt`).map((line) =>
    parseInt(line)
  );

  const firstResult = module.exports.checkExpenseReport(lines);
  const secondResult = module.exports.checkExpenseReportAgain(lines);

  console.log(firstResult);
  console.log(secondResult);
}
