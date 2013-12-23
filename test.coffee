# module deps
assert = require 'assert'
chalk = require 'chalk'
coffeelint = require 'coffeelint'

# SUT
reporter = require('./index').reporter


describe 'coffeelint-stylish', ->
    describe 'should prettily report coffeelint results', ->
        it 'with a filename', ->
            ret = false
            _log = process.stdout.write

            # mock on
            process.stdout.write = (str = '') ->
                ret = true if /my name is/ig.test chalk.stripColor str

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
                ret = true if /No problems/ig.test chalk.stripColor str

            # run reporter
            reporter '', coffeelint.lint 'yeah()', {}

            # mock out
            process.stdout.write = _log

            assert ret

        it 'even if they are bad (1 warn)', ->
            ret1 = false
            ret2 = false
            _log = process.stdout.write

            # mock on
            process.stdout.write = (str = '') ->
                ret1 = true if /line 1  Line contains a trailing semicolon/ig.test chalk.stripColor str
                ret2 = true if /1 warn/ig.test chalk.stripColor str

            # run reporter
            reporter '', coffeelint.lint 'yeah();', no_trailing_semicolons: level: 'warn'

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
                ret1 = true if /line 1  Line contains a trailing semicolon/ig.test chalk.stripColor str
                ret2 = true if /1 error/ig.test chalk.stripColor str

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
                ret1 = true if /line 1  Line contains a trailing semicolon/ig.test chalk.stripColor str
                ret2 = true if /1 error/ig.test chalk.stripColor str
                ret3 = true if /line 1  Unnecessary fat arrow/ig.test chalk.stripColor str
                ret4 = true if /1 warning/ig.test chalk.stripColor str

            # run reporter
            reporter 'test', coffeelint.lint 'do => yeah();', {}

            # mock out
            process.stdout.write = _log

            assert ret1
            assert ret2
