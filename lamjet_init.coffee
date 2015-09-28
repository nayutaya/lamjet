
Promise = require("promise")

console.log "init"

# stdin = require("get-stdin")
# stdin.buffer (line)->
#   console.log "line: #{line}"

stdout = process.stdout
stdin  = process.stdin
stdin.setEncoding("utf8")

question = (stdout, stdin, message, defaultValue)->
  stdout.write "#{message} [#{defaultValue}] "
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

Promise.resolve()
  .then (result)-> question(stdout, stdin, "hoge?", "yes")
  .then (result)->
    console.log(JSON.stringify({then: result}, null, 2))
  .then (result)->
    question(stdout, stdin, "foo?", "z")
  .then (result)->
    console.log(JSON.stringify({then: result}, null, 2))
