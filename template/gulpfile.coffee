
gulp        = require "gulp"
coffee      = require "gulp-coffee"
gutil       = require "gulp-util"
jasmine     = require "gulp-jasmine"
lambduhGulp = require "lambduh-gulp"

lambduhGulp gulp

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
