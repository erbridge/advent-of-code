const { readFileSync } = require("fs");

module.exports = (path) =>
  readFileSync(path, "utf8")
    .split("\n")
    .filter((line) => line);
