
fs   = require("fs")
path = require("path")
Promise = require("promise")

console.log "lamjet"
# TODO: バージョン番号を出力する

if process.argv[2] == "init"
  toolPath = path.join(path.dirname(process.argv[1]), "..")
  templatePath = path.join(toolPath, "template")

  readTemplate = (fileName)->
    filePath = path.join(templatePath, fileName)
    return new Promise (resolve, reject)->
      fs.readFile filePath, {encoding: "utf8"}, (error, body)->
        if error?
          reject(filePath: filePath, error: error)
        else
          resolve(filePath: filePath, body: body)

  basePath = path.resolve()
  writeArtifact = (fileName, body)->
    filePath = path.join(basePath, fileName)
    return new Promise (resolve, reject)->
      fs.writeFile filePath, body, {encoding: "utf8", flag: "w"}, (error)->
        if error?
          reject(filePath: filePath, error: error)
        else
          resolve(filePath: filePath, body: body)

  defaultFunctionName = path.basename(path.resolve())

  # TODO: 「package.json」が存在する場合、上書きの有無を確認する。

  makePackageJson = (options)->
    functionName = options?.functionName ? throw new Error("functionName")
    return readTemplate("package.json")
      .then (result)->
        result.body = result.body.replace(/FUNCTION-NAME/, functionName)
        return Promise.resolve(result)
      .then (result)-> writeArtifact("package.json", result.body)

  makeLambdaConfigJs = ->
    return readTemplate("lambda-config.js")
      .then (result)-> writeArtifact("lambda-config.js", result.body)

  makeGitIgnore = ->
    return readTemplate("gitignore")
      .then (result)-> writeArtifact(".gitignore", result.body)

  Promise.resolve()
    .then (result)-> makePackageJson(functionName: defaultFunctionName)
    .then (result)-> makeLambdaConfigJs()
    .then (result)-> makeGitIgnore()
    .then (result)->
      console.log(JSON.stringify({then: result}, null, 2))

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
