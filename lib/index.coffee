
coffee      = require "gulp-coffee"
gutil       = require "gulp-util"
jasmine     = require "gulp-jasmine"
lambduhGulp = require "lambduh-gulp"

del = require("del")
install = require("gulp-install")
zip = require("gulp-zip")
runSequence = require("run-sequence")

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

    gulp.task "install-dependencies", ->
      gulp.src("./out/package.json")
        .pipe(install({production: true}))

    gulp.task "archive-to-zip", ->
      gulp.src(["out/**/*"])
        .pipe(zip("out.zip"))
        .pipe(gulp.dest("./"))

    gulp.task "build-zip", (callback)->
      return runSequence(
        ["myclean"],
        ["mybuild"],
        ["copy-package-json"],
        ["install-dependencies"],
        ["archive-to-zip"],
        callback)

    # TODO: 「lambduh-gulp」に依存しないように修正する。
    lambduhGulp(gulp)

    # TODO: 削除予定。
    gulp.task "js", ->
      gulp.src("./src/*.coffee")
        .pipe(coffee()).on("error", gutil.log)
        .pipe(gulp.dest("./dist"))

    # TODO: サブディレクトリも含める。ディレクトリ名を変更する。
    gulp.task "test", ->
      gulp.src("./dist/*_spec.js")
        .pipe(jasmine({includeStackTrace: false}))

    # TODO: サブディレクトリも含める。ディレクトリ名を変更する。
    gulp.task "auto-test", ->
      gulp.watch("./src/*.coffee", ["default"])
      gulp.start("default")

    # TODO: 依存タスク名を変更する。
    gulp.task "default", ["js"], ->
      gulp.start("test")
