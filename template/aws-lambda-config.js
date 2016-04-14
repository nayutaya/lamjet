
var packageJson = require("./package.json")

module.exports = {
  functionName: packageJson.name,
  description: "v" + packageJson.version + ": " + packageJson.description,
  region: "{REGION}",
  role: "{ROLE}",
  memorySize: {MEMORY-SIZE},
  timeout: {TIMEOUT},
  runtime: "nodejs4.3",
  handler: "index.handler"
}
