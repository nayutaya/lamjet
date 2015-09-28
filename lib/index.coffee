
path = require("path")

Promise = require("promise")

coffee      = require "gulp-coffee"
gutil       = require "gulp-util"
jasmine     = require "gulp-jasmine"

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
      # console.log(JSON.stringify({config: config}, null, 2))
      lambda = new LambdaWrapper(region: config.Region)

      console.log "Loading zip file..."
      FsWrapper.readFile("./out.zip")
        .then (result)->
          zipBody = result.body
          createFunctionParam = {
            FunctionName: config.FunctionName,
            Description:  config.Description,
            Handler:      config.Handler,
            Role:         config.Role,
            Runtime:      config.Runtime,
            MemorySize:   config.MemorySize,
            Timeout:      config.Timeout,
            Code:         {ZipFile: zipBody},
          }
          # console.log(JSON.stringify({createFunctionParam: createFunctionParam}, null, 2))
          updateFunctionConfigurationParam = {
            FunctionName: config.FunctionName,
            Description:  config.Description,
            Handler:      config.Handler,
            Role:         config.Role,
            MemorySize:   config.MemorySize,
            Timeout:      config.Timeout,
          }
          # console.log(JSON.stringify({updateFunctionConfigurationParam: updateFunctionConfigurationParam}, null, 2))
          updateFunctionCodeParam = {
            FunctionName: config.FunctionName,
            ZipFile:      zipBody,
          }
          # console.log(JSON.stringify({updateFunctionCodeParam: updateFunctionCodeParam}, null, 2))

          console.log "Creating function..."
          return lambda.createFunction(createFunctionParam)
            .then (result)->
              console.log "Created function."
              return Promise.resolve(result)
            .catch (result)->
              if result?.error?.statusCode == 409 #
                console.log "Function already exist"
                console.log "Updating function configuration..."
                return lambda.updateFunctionConfiguration(updateFunctionConfigurationParam)
                  .then (result)->
                    console.log "Update function code..."
                    return lambda.updateFunctionCode(updateFunctionCodeParam)
                  .then (result)->
                    console.log "Updated function."
                    return Promise.resolve(result)
              else
                return Promise.reject(result)
        .then (result)->
          # console.log(JSON.stringify({then: result}, null, 2))
          console.log("Successful deploy function.")
          # callback()
        .catch (result)->
          # console.log(JSON.stringify({catch: result}, null, 2))
          console.log("Failed deploy function.")
          console.log(result)
          console.log(result.stack) if result?.stack?
          # callback(result)

    gulp.task "deploy", (callback)->
      return runSequence(
        ["build-zip"],
        ["deploy-to-aws-lambda"],
        callback)

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
