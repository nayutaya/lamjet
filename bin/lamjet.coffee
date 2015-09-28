# MEMO: for debug use
LamjetCommand = require("../lib/lamjet_command")
(new LamjetCommand(process.argv, console.log, process.stdout, process.stdin)).run()
