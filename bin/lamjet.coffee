
fs   = require("fs")
path = require("path")
Promise = require("promise")

console.log "lamjet"
# TODO: バージョン番号を出力する

if process.argv[2] == "init"
  defaultFunctionName = path.basename(path.resolve())
  defaultVersion      = "1.0.0"

  packageJson = JSON.stringify({
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
    devDependencies: {
      "coffee-script": "^1.10.0",
      "gulp": "^3.9.0",
      "gulp-coffee": "^2.3.1",
      "gulp-jasmine": "^2.1.0",
      "gulp-util": "^3.0.6",
      "jasmine": "^2.3.2",
      "lambduh-gulp": "^0.1.6",
    },
  }, null, 2)

  # TODO: 「package.json」が存在する場合、上書きの有無を確認する。
  packageJsonPath = path.join(path.resolve(), "package.json")
  console.log packageJson
  console.log packageJsonPath
  fs.writeFileSync(packageJsonPath, packageJson, encoding: "utf8", flag: "w")

  lambdaConfigJs = """
    module.exports = {
      FunctionName: "xxx",
      Description: "TODO",
      Handler: "index.handler",
      Role: "arn:aws:iam::ACCOUNTID:role/ROLENAME",
      Region: "REGION",
      Runtime: "nodejs",
      MemorySize: 128,
      Timeout: 3
    }
  """
  lambdaConfigJsPath = path.join(path.resolve(), "lambda-config.js")
  console.log lambdaConfigJs
  console.log lambdaConfigJsPath
  fs.writeFileSync(lambdaConfigJsPath, lambdaConfigJs, encoding: "utf8", flag: "w")
else
  console.log "Usage: lamjet init"
