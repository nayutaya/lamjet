
aws     = require("aws-sdk")
Promise = require("promise")

module.exports = class LambdaWrapper
  constructor: (options)->
    @lambda = new aws.Lambda(
      apiVersion: "2015-03-31",
      region: options.region)

  createFunction: (param)->
    self = this
    return new Promise (resolve, reject)->
      self.lambda.createFunction param, (error, data)->
        if error?
          reject(param: param, error: error)
        else
          resolve(param: param, data: data)

  updateFunctionConfiguration: (param)->
    self = this
    return new Promise (resolve, reject)->
      self.lambda.updateFunctionConfiguration param, (error, data)->
        if error?
          reject(param: param, error: error)
        else
          resolve(param: param, data: data)

  updateFunctionCode: (param)->
    self = this
    return new Promise (resolve, reject)->
      self.lambda.updateFunctionCode param, (error, data)->
        if error?
          reject(param: param, error: error)
        else
          resolve(param: param, data: data)
