
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

  makePackageJson: (options)->
    self = this
    functionName = options?.functionName ? throw new Error("functionName")
    return self.readTemplate("package.json")
      .then (result)->
        result.body = result.body.replace(/FUNCTION-NAME/, functionName)
        return Promise.resolve(result)
      .then (result)-> self.writeArtifact("package.json", result.body)

  copyTemplate: (source, destination)->
    self = this
    return self.readTemplate(source)
      .then (result)-> self.writeArtifact((destination ? source), result.body)

  init: ->
    self = this
    defaultFunctionName = path.basename(path.resolve())
    return Promise.resolve()
      .then (result)-> self.makePackageJson(functionName: defaultFunctionName)
      .then (result)-> self.copyTemplate("lambda-config.js")
      .then (result)-> self.copyTemplate("gitignore", ".gitignore")
      .then (result)-> self.copyTemplate("gulpfile.coffee")
      .then (result)-> self.copyTemplate("index.coffee", path.join("src", "index.coffee"))
      .then (result)-> self.copyTemplate("index_spec.coffee", path.join("src", "index_spec.coffee"))

  run: ->
    if @argv[2] == "init"
      @init()
        .then (result)->
          # console.log(JSON.stringify({then: result}, null, 2))
          console.log("initialized")
        .catch (result)->
          console.log(result)
          console.log(result.stack) if result?.stack?
    else
      console.log("Usage: lamjet init")

lamjetCommand = new LamjetCommand(process.argv)
lamjetCommand.run()
