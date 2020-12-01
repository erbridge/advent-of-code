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
};

if (require.main === module) {
  const { readFileSync } = require("fs");

  const input = readFileSync(`${__dirname}/input.txt`, "utf8")
    .split("\n")
    .map((line) => parseInt(line));

  const result = module.exports.checkExpenseReport(input);

  console.log(result);
}
