
exports.handler = (event, context)->
  console.log(JSON.stringify({event: event, context: context}, null, 2))
  context.succeed(event: event, context: context)
