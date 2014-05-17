# module deps
chalk = require 'chalk'
table = require 'text-table'

# sign language
is_win = process.platform is 'win32'
warn_sign = "#{if is_win then '' else '⚠'}"
err_sign = "#{if is_win then '' else '✖'}"
happy_sign = "#{if is_win then '' else '✔'}"

reporter = (filename = '', results = []) ->
    errs = 0
    warns = 0
    ret = ''

    ret = '\n' + chalk.underline(filename) + '\n' if filename

    # build log table
    ret += table results.map (result) ->
        {level, lineNumber, message, context} = result
        errs++ if level is 'error'
        warns++ if level is 'warn'

        # return line message
        [
            ''
            chalk.gray if level is 'error' then err_sign else warn_sign
            chalk.gray 'line ' + lineNumber
            chalk.blue message
            chalk.gray context or ''
        ]

    ret += '\n\n'

    # append summary line(s)
    if warns > 0
        ret += chalk.yellow(
            "#{warn_sign} #{warns} warning#{if warns is 1 then '' else 's'}"
        )
        ret += '\n' if errs > 0

    if errs > 0
        ret += chalk.red(
            "#{err_sign} #{errs} error#{if errs is 1 then '' else 's'}"
        )

    if errs is 0 and warns is 0
        ret += chalk.green "#{happy_sign} No problems"
        ret = '\n' + ret.trim()

    # print table and summary line(s)
    console.log ret + '\n'

module.exports = class StylishReporter
    # maintain backward compatibility from before
    # CoffeeLint supported external reporters
    @reporter: reporter

    constructor: (@error_report) ->

    publish: ->
        for filename, results of @error_report.paths
            StylishReporter.reporter filename, results
