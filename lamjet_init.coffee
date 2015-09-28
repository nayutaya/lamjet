
Promise = require("promise")

console.log "init"

# stdin = require("get-stdin")
# stdin.buffer (line)->
#   console.log "line: #{line}"

stdout = process.stdout
stdin  = process.stdin
stdin.setEncoding("utf8")

question = (stdout, stdin, message, defaultValue)->
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

configuration = (stdout, stdin, defaultConfig)->
  config = {}
  return Promise.resolve()
    .then (result)-> question(stdout, stdin, "Function name", defaultConfig.functionName)
    .then (result)-> config.functionName = result
    .then (result)-> question(stdout, stdin, "Region", defaultConfig.region)
    .then (result)-> config.region = result
    .then (result)-> question(stdout, stdin, "Role", defaultConfig.role)
    .then (result)-> config.role = result
    .then (result)-> question(stdout, stdin, "Memory size in MB", String(defaultConfig.memorySize))
    .then (result)-> config.memorySize = Number(result)
    .then (result)-> question(stdout, stdin, "Timeout in sec", String(defaultConfig.timeout))
    .then (result)-> config.timeout = Number(result)
    .then (result)-> stdin.pause()
    .then (result)-> Promise.resolve(config)

defaultConfig = {
  functionName: "defFunName",
  region: "us-east-1",
  role: "arn:aws:iam::ACCOUNTID:role/ROLENAME",
  memorySize: 128,
  timeout: 3,
}
configuration(stdout, stdin, defaultConfig)
  .then (result)->
    console.log(JSON.stringify({config: result}, null, 2))
