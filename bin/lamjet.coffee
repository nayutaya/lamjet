
fs      = require("fs")
path    = require("path")
mkdirp  = require("mkdirp")
Promise = require("promise")

console.log "lamjet"
# TODO: バージョン番号を出力する

if process.argv[2] == "init"
  toolPath     = path.join(path.dirname(process.argv[1]), "..")
  templatePath = path.join(toolPath, "template")
  artifactPath = path.resolve()

  readTemplate = (fileName)->
    filePath = path.join(templatePath, fileName)
    return new Promise (resolve, reject)->
      fs.readFile filePath, {encoding: "utf8"}, (error, body)->
        if error?
          reject(filePath: filePath, error: error)
        else
          resolve(filePath: filePath, body: body)

  writeArtifact = (fileName, body)->
    filePath = path.join(artifactPath, fileName)
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

  copyTemplate = (source, destination)->
    return readTemplate(source)
      .then (result)-> writeArtifact((destination ? source), result.body)

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
