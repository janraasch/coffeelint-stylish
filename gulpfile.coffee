gulp = require 'gulp'
coffee = require 'gulp-coffee'
{spawn} = require 'child_process'

# compile `.coffee`
gulp.task 'coffee', ->
    gulp.src(['index.coffee'])
        .pipe(coffee bare: true)
        .pipe(gulp.dest './')

# run tests
gulp.task 'test', ['coffee'], ->
    spawn 'npm', ['test'], stdio: 'inherit'

# try outs
gulp.task 'pony', (cb) ->
    reporter = require('./index').reporter
    coffeelint = require 'coffeelint'
    fs = require 'fs'
    join = require('path').join

    reporter 'pony.coffee', coffeelint.lint String fs.readFileSync join __dirname, '/pony.coffee'
    cb()

# workflow
gulp.task 'default', ->
    gulp.run 'coffee'

    gulp.watch ['index.coffee', 'test.coffee'], ->
        gulp.run 'test'
