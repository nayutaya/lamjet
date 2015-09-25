#! /usr/bin/env node
(function() {
  var LamjetCommand = require("../lib/lamjet_command");
  (new LamjetCommand(process.argv, console.log)).run();
}).call(this);
