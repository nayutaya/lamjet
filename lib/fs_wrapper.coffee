
fs      = require("fs")
Promise = require("promise")

module.exports = class FsWrapper
  @readFile: (filePath)->
    return new Promise (resolve, reject)->
      fs.readFile filePath, {}, (error, body)->
        if error?
          reject(filePath: filePath, error: error)
        else
          resolve(filePath: filePath, body: body)
