
fs      = require("fs")
path    = require("path")
mkdirp  = require("mkdirp")
Promise = require("promise")

console.log "lamjet"
# TODO: バージョン番号を出力する

class LamjetCommand
  constructor: (@argv)->
    @toolPath     = path.join(path.dirname(@argv[1]), "..")
    @templatePath = path.join(@toolPath, "template")
    @currentPath  = path.resolve()
    @artifactPath = @currentPath

  readTemplate: (fileName)->
    filePath = path.join(@templatePath, fileName)
    return new Promise (resolve, reject)->
      fs.readFile filePath, {encoding: "utf8"}, (error, body)->
        if error?
          reject(filePath: filePath, error: error)
        else
          resolve(filePath: filePath, body: body)

  writeArtifact: (fileName, body)->
    filePath = path.join(@artifactPath, fileName)
    return Promise.resolve()
      .then (result)->
        return new Promise (resolve, reject)->
          mkdirp path.dirname(filePath), (error)->
            if error?
              reject(error: error)
            else
              resolve()
      .then (result)->
        return new Promise (resolve, reject)->
          # TODO: ファイルが存在する場合、上書きの有無を確認する。
          console.log("write #{filePath}...")
          fs.writeFile filePath, body, {encoding: "utf8", flag: "w"}, (error)->
            if error?
              reject(filePath: filePath, error: error)
            else
              resolve(filePath: filePath, body: body)

if process.argv[2] == "init"
  lamjetCommand = new LamjetCommand(process.argv)
  console.log lamjetCommand

  toolPath     = path.join(path.dirname(process.argv[1]), "..")
  templatePath = path.join(toolPath, "template")
  artifactPath = path.resolve()

  defaultFunctionName = path.basename(path.resolve())

  makePackageJson = (options)->
    functionName = options?.functionName ? throw new Error("functionName")
    return lamjetCommand.readTemplate("package.json")
      .then (result)->
        result.body = result.body.replace(/FUNCTION-NAME/, functionName)
        return Promise.resolve(result)
      .then (result)-> lamjetCommand.writeArtifact("package.json", result.body)

  copyTemplate = (source, destination)->
    return lamjetCommand.readTemplate(source)
      .then (result)-> lamjetCommand.writeArtifact((destination ? source), result.body)

  Promise.resolve()
    .then (result)-> makePackageJson(functionName: defaultFunctionName)
    .then (result)-> copyTemplate("lambda-config.js")
    .then (result)-> copyTemplate("gitignore", ".gitignore")
    .then (result)-> copyTemplate("gulpfile.coffee")
    .then (result)-> copyTemplate("index.coffee", path.join("src", "index.coffee"))
    .then (result)-> copyTemplate("index_spec.coffee", path.join("src", "index_spec.coffee"))
    .then (result)->
      # console.log(JSON.stringify({then: result}, null, 2))
      console.log("initialized")
    .catch (result)->
      console.log(result)

else
  console.log "Usage: lamjet init"
