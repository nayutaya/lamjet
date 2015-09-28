
path = require("path")

coffee      = require "gulp-coffee"
gutil       = require "gulp-util"
jasmine     = require "gulp-jasmine"
lambduhGulp = require "lambduh-gulp"

del = require("del")
install = require("gulp-install")
zip = require("gulp-zip")
runSequence = require("run-sequence")

FsWrapper     = require("./fs_wrapper")
LambdaWrapper = require("./lambda_wrapper")

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

    gulp.task "deploy-to-aws-lambda", (callback)->
      config = require(path.join(process.cwd(), "lambda-config.js"))
      # config = require("./lambda-config.js")
      console.log config

      # lambda = new aws.Lambda(
      #   apiVersion: "2015-03-31",
      #   region: config.Region)
      # console.log lambda
      lambda = new LambdaWrapper(region: config.Region)

      FsWrapper.readFile("./out.zip")
        .then (result)->
          zipBody = result.body
          param = {
            FunctionName: config.FunctionName,
            Description: config.Description,
            Handler: config.Handler,
            Role: config.Role,
            Runtime: config.Runtime,
            MemorySize: config.MemorySize,
            Timeout: config.Timeout,
            Code: {ZipFile: zipBody},
          }
          console.log param
          return lambda.createFunction(param)
            .then (result)->
              console.log "created"
              return Promise.resolve(result)
            .catch (result)->
              if result.error.statusCode == 409 # Function already exist
                console.log result.error.statusCode
                param = {
                  FunctionName: config.FunctionName,
                  Description: config.Description,
                  Handler: config.Handler,
                  Role: config.Role,
                  MemorySize: config.MemorySize,
                  Timeout: config.Timeout,
                }
                console.log param
                return lambda.updateFunctionConfiguration(param)
                  .then (result)->
                    param = {
                      FunctionName: config.FunctionName,
                      ZipFile: zipBody,
                    }
                    console.log param
                    return lambda.updateFunctionCode(param)
              else
                return Promise.reject(result)
        .then (result)->
          # console.log(JSON.stringify({then: result}, null, 2))
          console.log({then: result})
          # callback()
        .catch (result)->
          # console.log(JSON.stringify({catch: result}, null, 2))
          console.log({catch: result})
          console.log(result.stack) if result?.stack?
          # callback(result)


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
