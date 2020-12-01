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

  const lines = readIntegersFromFile(`${__dirname}/input.txt`);

  const firstResult = module.exports.checkExpenseReport(lines);
  const secondResult = module.exports.checkExpenseReportAgain(lines);

  console.log(firstResult);
  console.log(secondResult);
}
