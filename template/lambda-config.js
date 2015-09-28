
package = require("./package.json")

module.exports = {
  FunctionName: package.name,
  Description: "v" + package.version + ": " + package.description,
  Handler: "index.handler",
  Role: "{ROLE}",
  Region: "{REGION}",
  Runtime: "nodejs",
  MemorySize: {MEMORY-SIZE},
  Timeout: {TIMEOUT}
}
