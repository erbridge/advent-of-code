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
  const { readFileSync } = require("fs");

  const input = readFileSync(`${__dirname}/input.txt`, "utf8")
    .split("\n")
    .map((line) => parseInt(line));

  const firstResult = module.exports.checkExpenseReport(input);
  const secondResult = module.exports.checkExpenseReportAgain(input);

  console.log(firstResult);
  console.log(secondResult);
}
