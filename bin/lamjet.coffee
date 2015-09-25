
fs   = require("fs")
path = require("path")
Promise = require("promise")

console.log "lamjet"
# TODO: バージョン番号を出力する

if process.argv[2] == "init"
  toolPath = path.join(path.dirname(process.argv[1]), "..")
  templatePath = path.join(toolPath, "template")

  defaultFunctionName = path.basename(path.resolve())

  packageJson = fs.readFileSync(path.join(templatePath, "package.json"), encoding: "utf8")
  packageJson = packageJson.replace(/FUNCTION-NAME/, defaultFunctionName)
  # TODO: 「package.json」が存在する場合、上書きの有無を確認する。
  packageJsonPath = path.join(path.resolve(), "package.json")
  console.log packageJson
  console.log packageJsonPath
  fs.writeFileSync(packageJsonPath, packageJson + "\n", encoding: "utf8", flag: "w")

  lambdaConfigJs     = fs.readFileSync(path.join(templatePath, "lambda-config.js"), encoding: "utf8")
  lambdaConfigJsPath = path.join(path.resolve(), "lambda-config.js")
  console.log lambdaConfigJs
  console.log lambdaConfigJsPath
  fs.writeFileSync(lambdaConfigJsPath, lambdaConfigJs, encoding: "utf8", flag: "w")

  gitignore     = fs.readFileSync(path.join(templatePath, "gitignore"), encoding: "utf8")
  gitignorePath = path.join(path.resolve(), ".gitignore")
  console.log gitignore
  console.log gitignorePath
  fs.writeFileSync(gitignorePath, gitignore, encoding: "utf8", flag: "w")

  gulpfileCoffee     = fs.readFileSync(path.join(templatePath, "gulpfile.coffee"), encoding: "utf8")
  gulpfileCoffeePath = path.join(path.resolve(), "gulpfile.coffee")
  console.log gulpfileCoffee
  console.log gulpfileCoffeePath
  fs.writeFileSync(gulpfileCoffeePath, gulpfileCoffee, encoding: "utf8", flag: "w")

  srcPath = path.join(path.resolve(), "src")
  console.log srcPath
  if !fs.existsSync(srcPath)
    fs.mkdirSync(srcPath)

  indexCoffee     = fs.readFileSync(path.join(templatePath, "index.coffee"), encoding: "utf8")
  indexCoffeePath = path.join(srcPath, "index.coffee")
  console.log indexCoffee
  console.log indexCoffeePath
  fs.writeFileSync(indexCoffeePath, indexCoffee, encoding: "utf8", flag: "w")

  indexSpecCoffee     = fs.readFileSync(path.join(templatePath, "index_spec.coffee"), encoding: "utf8")
  indexSpecCoffeePath = path.join(srcPath, "index_spec.coffee")
  console.log indexSpecCoffee
  console.log indexSpecCoffeePath
  fs.writeFileSync(indexSpecCoffeePath, indexSpecCoffee, encoding: "utf8", flag: "w")
else
  console.log "Usage: lamjet init"
