
package = require("./package.json")

module.exports = {
  functionName: package.name,
  description: "v" + package.version + ": " + package.description,
  region: "{REGION}",
  role: "{ROLE}",
  memorySize: {MEMORY-SIZE},
  timeout: {TIMEOUT},
  runtime: "nodejs",
  handler: "index.handler"
}
