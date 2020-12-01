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
  const readIntegersFromFile = require("../utils/readIntegersFromFile");

  const input = readIntegersFromFile(`${__dirname}/input.txt`, "utf8");

  const firstResult = module.exports.checkExpenseReport(input);
  const secondResult = module.exports.checkExpenseReportAgain(input);

  console.log(firstResult);
  console.log(secondResult);
}
