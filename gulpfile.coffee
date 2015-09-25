
gulp    = require "gulp"
coffee  = require "gulp-coffee"
gutil   = require "gulp-util"
jasmine = require "gulp-jasmine"
del     = require "del"

gulp.task "clean", (callback)->
  del(["./lib/*.js", "./bin/*.js"], callback)

gulp.task "build", ->
  gulp.src(["./lib/*.coffee"])
    .pipe(coffee()).on("error", gutil.log)
    .pipe(gulp.dest("./lib"))
  gulp.src(["./bin/*.coffee"])
    .pipe(coffee()).on("error", gutil.log)
    .pipe(gulp.dest("./bin"))

gulp.task "test", ["build"], ->
  gulp.src("./lib/*_spec.js")
    .pipe(jasmine({includeStackTrace: false}))

gulp.task "auto-test", ->
  gulp.watch("./lib/*.coffee", ["test"])
  gulp.start("test")

gulp.task "default", ["test"], ->
