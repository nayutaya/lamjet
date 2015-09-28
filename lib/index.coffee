
coffee      = require "gulp-coffee"
gutil       = require "gulp-util"
jasmine     = require "gulp-jasmine"
lambduhGulp = require "lambduh-gulp"

del = require("del")

module.exports = class Lamjet
  @setup: (gulp)->
    # TODO: 「clean」に名称変更する。
    gulp.task "myclean", (callback)->
      del(["./out", "./out.zip"], callback)

    # TODO: 「build」に名称変更する。
    gulp.task "mybuild", ->
      gulp.src("./src/**/*.coffee")
        .pipe(coffee()).on("error", gutil.log)
        .pipe(gulp.dest("./out"))

    gulp.task "copy-package-json", ->
      gulp.src("./package.json").
        pipe(gulp.dest("./out"))

    # TODO: 「lambduh-gulp」に依存しないように修正する。
    lambduhGulp(gulp)

    gulp.task "js", ->
      gulp.src("./src/*.coffee")
        .pipe(coffee()).on("error", gutil.log)
        .pipe(gulp.dest("./dist"))

    gulp.task "test", ->
      gulp.src("./dist/*_spec.js")
        .pipe(jasmine({includeStackTrace: false}))

    gulp.task "auto-test", ->
      gulp.watch("./src/*.coffee", ["default"])
      gulp.start("default")

    gulp.task "default", ["js"], ->
      gulp.start("test")
