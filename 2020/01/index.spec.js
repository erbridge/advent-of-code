const { checkExpenseReport, checkExpenseReportAgain } = require(".");

describe("checkExpenseReport", () => {
  it("finds the product of the two entries that sum to 2020", () => {
    const lines = [1721, 979, 366, 299, 675, 1456];

    const result = checkExpenseReport(lines);

    expect(result).toEqual(514579);
  });
});

describe("checkExpenseReportAgain", () => {
  it("finds the product of the three entries that sum to 2020", () => {
    const lines = [1721, 979, 366, 299, 675, 1456];

    const result = checkExpenseReportAgain(lines);

    expect(result).toEqual(241861950);
  });
});
