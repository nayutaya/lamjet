
fs   = require("fs")
path = require("path")
Promise = require("promise")

console.log "lamjet"
# TODO: バージョン番号を出力する

if process.argv[2] == "init"
  defaultFunctionName = path.basename(path.resolve())
  defaultVersion      = "1.0.0"

  packageInfo = {
    private: true,
    name: defaultFunctionName,
    version: defaultVersion,
    description: "TODO:",
    scripts: {
      test: "gulp",
      zip: "echo TODO",
      upload: "echo TODO",
      deploy: "echo TODO",
    },
    dependencies: {},
    devDependencies: {},
  }


  packageJsonPath = path.join(path.resolve(), "package.json")
  console.log packageJsonPath
  exists = fs.existsSync(packageJsonPath)
  console.log JSON.stringify({exists: exists}, null, 2)
  packageJson = JSON.stringify(packageInfo, null, 2)
  console.log packageJson
  fs.writeFileSync(packageJsonPath, packageJson, encoding: "utf8", flag: "w")


else
  console.log "Usage: lamjet init"
