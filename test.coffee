# module deps
assert = require 'assert'
chalk = require 'chalk'
coffeelint = require 'coffeelint'

# SUT
StylishReporter = require './index'
reporter = StylishReporter.reporter


describe 'coffeelint-stylish', ->
    describe 'should export a constructor', ->
        fake_error_report =
            paths:
                'index.coffee': ['results_of_index.coffee']
                'test.coffee': ['results_of_test.coffee']
        stylish_instance = null

        beforeEach ->
            stylish_instance = new StylishReporter fake_error_report

        it 'satisfying the coffeelint external reporter api', ->
            assert.strictEqual stylish_instance.error_report, fake_error_report
            assert.strictEqual typeof stylish_instance.publish, 'function'

        it 'with instances referring back to .reporter internally', ->
            _reporter = StylishReporter.reporter
            ret1 = false
            ret2 = false

            # mock on
            StylishReporter.reporter = (filename, results) ->
                if (filename is 'index.coffee') and
                    (results is fake_error_report.paths['index.coffee']) and
                    (ret1 is false)
                    then ret1 = true

                if (filename is 'test.coffee') and
                    (results is fake_error_report.paths['test.coffee']) and
                    (ret2 is false)
                    then ret2 = true

                undefined

            # run reporter
            stylish_instance.publish()

            # mock out
            StylishReporter.reporter = _reporter

            assert ret1
            assert ret2

    describe '.reporter should prettily report coffeelint results', ->
        it 'with a filename', ->
            ret = false
            _log = process.stdout.write

            # mock on
            process.stdout.write = (str = '') ->
                ret = /my name is/ig.test chalk.stripColor str

            # run reporter
            reporter 'my name is', coffeelint.lint 'yeah()', {}

            # mock out
            process.stdout.write = _log

            assert ret

        it 'without a filename', ->
            ret = false
            _log = process.stdout.write

            # mock on
            process.stdout.write = (str = '') ->
                ret = /No problems/ig.test chalk.stripColor str

            # run reporter
            reporter null, coffeelint.lint 'yeah()', {}

            # mock out
            process.stdout.write = _log

            assert ret

        it 'even if they are bad (1 warn)', ->
            ret1 = false
            ret2 = false
            _log = process.stdout.write

            # mock on
            process.stdout.write = (str = '') ->
                ret1 = /line 1  Line contains a trailing semicolon/ig.test(
                    chalk.stripColor str
                )
                ret2 = /1 warn/ig.test chalk.stripColor str

            # run reporter
            reporter '', coffeelint.lint(
                'yeah();',
                no_trailing_semicolons: level: 'warn'
            )

            # mock out
            process.stdout.write = _log

            assert ret1
            assert ret2

        it 'even if they are worse (1 error)', ->
            ret1 = false
            ret2 = false
            _log = process.stdout.write

            # mock on
            process.stdout.write = (str = '') ->
                ret1 = /line 1  Line contains a trailing semicolon/ig.test(
                    chalk.stripColor str
                )
                ret2 = /1 error/ig.test chalk.stripColor str

            # run reporter
            reporter '', coffeelint.lint 'yeah();', {}

            # mock out
            process.stdout.write = _log

            assert ret1
            assert ret2

        it 'even if they are bad and worse', ->
            ret1 = false
            ret2 = false
            ret3 = false
            ret4 = false
            _log = process.stdout.write

            # mock on
            process.stdout.write = (str = '') ->
                ret1 = /line 1  Line contains a trailing semicolon/ig.test(
                    chalk.stripColor str
                )
                ret2 = /1 error/ig.test chalk.stripColor str
                ret3 = /line 1  Unnecessary fat arrow/ig.test(
                    chalk.stripColor str
                )
                ret4 = /1 warning/ig.test chalk.stripColor str

            # run reporter
            reporter 'test', coffeelint.lint 'do => yeah();', {}

            # mock out
            process.stdout.write = _log

            assert ret1
            assert ret2

        it 'even if they are double bad', ->
            warns = false
            _log = process.stdout.write


            # mock on
            process.stdout.write = (str = '') ->
                warns = /2 warnings/ig.test chalk.stripColor str

            # run reporter
            reporter 'test', coffeelint.lint 'do => => yeah()'

            # mock out
            process.stdout.write = _log

            assert warns

        it 'even if they are double worse', ->
            warns = false
            _log = process.stdout.write


            # mock on
            process.stdout.write = (str = '') ->
                warns = /2 errors/ig.test chalk.stripColor str

            # run reporter
            reporter 'test', coffeelint.lint(
                'do => => yeah()',
                no_unnecessary_fat_arrows: level: 'error'
            )

            # mock out
            process.stdout.write = _log

            assert warns

        it 'even if there are no results', ->
            ret = false
            _log = process.stdout.write

            # mock on
            process.stdout.write = (str = '') ->
                ret = /no results/ig.test chalk.stripColor str

            # run reporter
            reporter 'no results'

            # mock out
            process.stdout.write = _log

            assert ret
