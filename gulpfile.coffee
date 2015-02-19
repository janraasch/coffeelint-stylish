gulp = require 'gulp'
coffee = require 'gulp-coffee'
del = require 'del'
{log,colors} = require 'gulp-util'
{spawn} = require 'child_process'

# compile `.coffee`
gulp.task 'coffee', ->
    gulp.src ['index.coffee']
        .pipe coffee bare: true
        .pipe gulp.dest './'

# remove `index.js` and `coverage` dir
gulp.task 'clean', (cb) ->
    del ['index.js', 'coverage'], cb

# run tests
gulp.task 'test', ['coffee'], ->
    spawn 'npm', ['test'], stdio: 'inherit'

# try outs
gulp.task 'pony', (cb) ->
    reporter = require('./index').reporter
    coffeelint = require 'coffeelint'
    fs = require 'fs'
    join = require('path').join

    reporter 'pony.coffee', coffeelint.lint(
        String fs.readFileSync join __dirname, '/pony.coffee'
    )

    log 'Empty filename'
    reporter null, coffeelint.lint(
        String fs.readFileSync join __dirname, '/pony.coffee'
    )

    log 'Empty results'
    reporter 'filename.coffee'

    log 'Both empty'
    reporter

    cb()

# workflow
gulp.task 'default', ['coffee'], ->
    gulp.watch ['index.coffee', 'test.coffee'], ['test']
