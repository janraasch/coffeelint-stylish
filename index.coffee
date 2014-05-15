# module deps
chalk = require 'chalk'
table = require 'text-table'

# sign language
isWin = process.platform is 'win32'
warnSign = "#{if isWin then '' else '⚠'}"
errSign = "#{if isWin then '×' else '✖'}"
happySign = "#{if isWin then '√' else '✔'}"

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
            chalk.gray if level is 'error' then errSign else warnSign
            chalk.gray 'line ' + lineNumber
            chalk.cyan message
            chalk.gray context or ''
        ]

    ret += '\n\n'

    # append summary line(s)
    if warns > 0
        ret += chalk.yellow(
            "#{warnSign} #{warns} warning#{if warns is 1 then '' else 's'}"
        )
        ret += '\n' if errs > 0

    if errs > 0
        ret += chalk.red(
            "#{errSign} #{errs} error#{if errs is 1 then '' else 's'}"
        )

    if errs is 0 and warns is 0
        ret += chalk.green "#{happySign} No problems"
        ret = '\n' + ret.trim()

    # print table and summary line(s)
    console.log ret + '\n'

module.exports = class StylishReporter
    # maintain backward compatibility from before
    # CoffeeLint supported external reporters
    @reporter: reporter

    constructor: (@errorReport) ->

    publish: ->
        for filename, results of @errorReport.paths
            reporter filename, results
