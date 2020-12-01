const { readFileSync } = require("fs");

module.exports = (path) =>
  readFileSync(path, "utf8")
    .split("\n")
    .map((line) => parseInt(line));
