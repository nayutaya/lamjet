
Promise = require("promise")

console.log "init"

# stdin = require("get-stdin")
# stdin.buffer (line)->
#   console.log "line: #{line}"

stdout = process.stdout
stdin  = process.stdin
stdin.setEncoding("utf8")

question = (stdout, stdin, message, defaultValue)->
  # TODO: 改行しない方法を調べる
  stdout.write "#{message} [#{defaultValue}] "
  buffer = ""
  pattern = /^(.*?)\n/
  return new Promise (resolve, reject)->
    stdin.on "readable", ->
      while chunk = stdin.read()
        buffer += chunk
      # console.log(JSON.stringify({buffer: buffer}, null, 2))
      match = pattern.exec(buffer)
      if match?
        if match[1] == ""
          resolve(defaultValue)
        else
          resolve(match[1])
    stdin.on "end", ->
      resolve(defaultValue)


question(stdout, stdin, "hoge?", "yes")
  .then (result)->
    console.log(JSON.stringify({then: result}, null, 2))
