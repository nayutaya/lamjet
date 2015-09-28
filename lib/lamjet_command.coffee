
fs      = require("fs")
path    = require("path")
mkdirp  = require("mkdirp")
Promise = require("promise")

module.exports = class LamjetCommand
  constructor: (@argv, @print, @stdout, @stdin)->
    @toolPath     = path.join(__dirname, "..")
    @templatePath = path.join(@toolPath, "template")
    @currentPath  = path.resolve()
    @artifactPath = @currentPath

  readFile: (filePath)->
    return new Promise (resolve, reject)->
      fs.readFile filePath, {encoding: "utf8"}, (error, body)->
        if error?
          reject(filePath: filePath, error: error)
        else
          resolve(filePath: filePath, body: body)

  writeFile: (filePath, body)->
    return new Promise (resolve, reject)->
      fs.writeFile filePath, body, {encoding: "utf8", flag: "w"}, (error)->
        if error?
          reject(filePath: filePath, error: error)
        else
          resolve(filePath: filePath, body: body)

  makeDirectory: (dirPath)->
    return new Promise (resolve, reject)->
      mkdirp dirPath, (error)->
        if error?
          reject(error: error)
        else
          resolve()

  readTemplate: (fileName)->
    return @readFile(path.join(@templatePath, fileName))

  writeArtifact: (fileName, body)->
    self = this
    filePath = path.join(@artifactPath, fileName)
    return Promise.resolve()
      .then (result)-> self.makeDirectory(path.dirname(filePath))
      .then (result)->
        # TODO: ファイルが存在する場合、上書きの有無を確認する。
        self.print("write #{filePath}")
        return self.writeFile(filePath, body)

  makePackageJson: (options)->
    self = this
    functionName = options?.functionName ? throw new Error("functionName")
    return self.readTemplate("package.json")
      .then (result)->
        result.body = result.body.replace(/FUNCTION-NAME/, functionName)
        return Promise.resolve(result)
      .then (result)-> self.writeArtifact("package.json", result.body)

  makeLambdaConfigJs: (options)->
    self = this
    functionName = options?.functionName ? throw new Error("functionName")
    return self.readTemplate("lambda-config.js")
      .then (result)->
        result.body = result.body.replace(/FUNCTION-NAME/, functionName)
        return Promise.resolve(result)
      .then (result)-> self.writeArtifact("lambda-config.js", result.body)

  copyTemplate: (source, destination)->
    self = this
    return self.readTemplate(source)
      .then (result)-> self.writeArtifact((destination ? source), result.body)

  question: (stdout, stdin, message, defaultValue)->
    stdout.write "#{message} [#{defaultValue}] ? "
    buffer  = ""
    pattern = /^(.*?)\n/

    return new Promise (resolve, reject)->
      onReadable = ->
        while chunk = stdin.read()
          buffer += chunk
        match = pattern.exec(buffer)
        if match?
          stdin.removeListener "readable", onReadable
          stdin.removeListener "end", onEnd
          if match[1] == ""
            resolve(defaultValue)
          else
            resolve(match[1])

      onEnd = ->
        stdin.removeListener "readable", onReadable
        stdin.removeListener "end", onEnd
        reject()

      stdin.on "readable", onReadable
      stdin.on "end", onEnd

  configuration: (stdout, stdin, defaultConfig)->
    self = this
    config = {}
    return Promise.resolve()
      .then (result)-> self.question(stdout, stdin, "Function name", defaultConfig.functionName)
      .then (result)-> config.functionName = result
      .then (result)-> self.question(stdout, stdin, "Region", defaultConfig.region)
      .then (result)-> config.region = result
      .then (result)-> self.question(stdout, stdin, "Role", defaultConfig.role)
      .then (result)-> config.role = result
      .then (result)-> self.question(stdout, stdin, "Memory size in MB", String(defaultConfig.memorySize))
      .then (result)-> config.memorySize = Number(result)
      .then (result)-> self.question(stdout, stdin, "Timeout in sec", String(defaultConfig.timeout))
      .then (result)-> config.timeout = Number(result)
      .then (result)-> stdin.pause()
      .then (result)-> Promise.resolve(config)

  init: ->
    self = this
    defaultConfig = {
      functionName: path.basename(path.resolve()),
      region: "us-east-1",
      role: "arn:aws:iam::ACCOUNTID:role/ROLENAME",
      memorySize: 128,
      timeout: 3,
    }
    config = null
    return Promise.resolve()
      .then (result)-> self.configuration(self.stdout, self.stdin, defaultConfig)
      .then (result)->
        console.log(JSON.stringify({config: result}, null, 2))
        config = result
      .then (result)-> self.makePackageJson(config)
      .then (result)-> self.makeLambdaConfigJs(config)
      .then (result)-> self.copyTemplate("gitignore", ".gitignore")
      .then (result)-> self.copyTemplate("gulpfile.coffee")
      .then (result)-> self.copyTemplate("index.coffee", path.join("src", "index.coffee"))
      .then (result)-> self.copyTemplate("index_spec.coffee", path.join("src", "index_spec.coffee"))

  run: ->
    self = this
    self.print("lamjet v" + require("../package.json").version)
    if self.argv[2] == "init"
      self.init()
        .then (result)->
          # self.print(JSON.stringify({then: result}, null, 2))
          self.print("initialized")
        .catch (result)->
          self.print(result)
          self.print(result.stack) if result?.stack?
    else
      self.print("Usage: lamjet init")
