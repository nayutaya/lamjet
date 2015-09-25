
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
      zip: "gulp lambda-zip",
      deploy: "gulp zipload",
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
  fs.writeFileSync(packageJsonPath, packageJson + "\n", encoding: "utf8", flag: "w")

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
  fs.writeFileSync(lambdaConfigJsPath, lambdaConfigJs + "\n", encoding: "utf8", flag: "w")

  gitignore = """
    /node_modules/
    /dist/
    /dist.zip
  """
  gitignorePath = path.join(path.resolve(), ".gitignore")
  console.log gitignore
  console.log gitignorePath
  fs.writeFileSync(gitignorePath, gitignore + "\n", encoding: "utf8", flag: "w")

  gulpfileCoffee = """
    gulp        = require "gulp"
    coffee      = require "gulp-coffee"
    gutil       = require "gulp-util"
    jasmine     = require "gulp-jasmine"
    lambduhGulp = require "lambduh-gulp"

    lambduhGulp gulp

    gulp.task "js", ->
      gulp.src("./src/*.coffee")
        .pipe(coffee()).on("error", gutil.log)
        .pipe(gulp.dest("./dist"))

    gulp.task "test", ->
      gulp.src("./dist/*_spec.js")
        .pipe(jasmine({includeStackTrace: false}))

    gulp.task "auto-test", ->
      gulp.watch("./src/*.coffee", ["default"])
      gulp.start("default")

    gulp.task "default", ["js"], ->
      gulp.start("test")
  """
  gulpfileCoffeePath = path.join(path.resolve(), "gulpfile.coffee")
  console.log gulpfileCoffee
  console.log gulpfileCoffeePath
  fs.writeFileSync(gulpfileCoffeePath, gulpfileCoffee + "\n", encoding: "utf8", flag: "w")

  # fs.mkdirSync()
  srcPath = path.join(path.resolve(), "src")
  console.log srcPath
  if !fs.existsSync(srcPath)
    fs.mkdirSync(srcPath)

  toolPath = path.join(path.dirname(process.argv[1]), "..")
  templatePath = path.join(toolPath, "template")
  indexCoffee     = fs.readFileSync(path.join(templatePath, "index.coffee"), encoding: "utf8")
  indexCoffeePath = path.join(srcPath, "index.coffee")
  console.log indexCoffee
  console.log indexCoffeePath
  fs.writeFileSync(indexCoffeePath, indexCoffee + "\n", encoding: "utf8", flag: "w")

  indexSpecCoffee     = fs.readFileSync(path.join(templatePath, "index_spec.coffee"), encoding: "utf8")
  indexSpecCoffeePath = path.join(srcPath, "index_spec.coffee")
  console.log indexSpecCoffee
  console.log indexSpecCoffeePath
  fs.writeFileSync(indexSpecCoffeePath, indexSpecCoffee + "\n", encoding: "utf8", flag: "w")
else
  console.log "Usage: lamjet init"
