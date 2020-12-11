const { checkExpenseReport, checkExpenseReportAgain } = require(".");
const readLinesFromFile = require("../utils/readLinesFromFile");

describe("checkExpenseReport", () => {
  it("finds the product of the two entries that sum to 2020", () => {
    const lines = [1721, 979, 366, 299, 675, 1456];

    const result = checkExpenseReport(lines);

    expect(result).toEqual(514579);
  });

  it("finds the correct result from the expense report", () => {
    const lines = readLinesFromFile(`${__dirname}/input.txt`).map((line) =>
      parseInt(line)
    );

    const result = checkExpenseReport(lines);

    expect(result).toEqual(1007104);
  });
});

describe("checkExpenseReportAgain", () => {
  it("finds the product of the three entries that sum to 2020", () => {
    const lines = [1721, 979, 366, 299, 675, 1456];

    const result = checkExpenseReportAgain(lines);

    expect(result).toEqual(241861950);
  });

  it("finds the correct result from the expense report", () => {
    const lines = readLinesFromFile(`${__dirname}/input.txt`).map((line) =>
      parseInt(line)
    );

    const result = checkExpenseReportAgain(lines);

    expect(result).toEqual(18847752);
  });
});
