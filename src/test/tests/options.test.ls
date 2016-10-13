{assert} = require \chai
require \../helper/autoreload .expose global

require! {
  '../../lib/option':      {OptionHelper}
}

option-list =
  * * label: "port"
      type:  "number"
      short: "p"
      def:   80

    * label: "watch"
      type:  "pattern"
      short: "w"
      def:   "**.watched"

    * label: "reload"
      type:  "pattern"
      short: "r"
      def:   "**.reload"

    * label: "boolvar"
      type:  "boolean"
      short: "b"
      def:   false

    * label: "booltrue"
      type:  "boolean"
      short: "t"
      def:   true

describe "option helper", ->

  It "should parse options", ->
    opt = new OptionHelper option-list

    {parsed,unknown} = opt.parse <[
      --port=1000 --watch ** --no-test
    ]>

    assert.equal parsed.port.length,   1,           "port should be 1 element array of string"
    assert.equal parsed.port.0,        "1000",      "port should be parsed properly"
    assert.equal parsed.watch.length,  1,           "pattern should be 1elem"
    assert.equal parsed.watch.0,       "**",        "pattern should be parsed as a string"
    assert.equal typeof parsed.test,   "undefined", "unknown flag should be excluded from parsed"
    assert.not-equal typeof unknown.full.test,"undefined", "unknown flag should be included in unknown"
    assert.is-not-ok        unknown.full.test[0],                 "negated flag should be false"

  It "should assure options", ->
    opt = new OptionHelper option-list

    {parsed,unknown} = opt.parse <[
      --port=1000 --watch *.log --port=100 --watch *.txt --reload --no-help
    ]>

    assured = opt.assure parsed

    assert.equal typeof assured.port, "number",     "port should be a number"
    assert.equal assured.port, 100,                 "port should be a last option"

    assured.watch  = OptionHelper.read-pattern assured.watch
    assured.reload = OptionHelper.read-pattern assured.reload

    assert.equal typeof assured.watch, "function",  "assured pattern should be a function"
    assert.equal typeof assured.reload, "function", "assured pattern should be a function"
    assert        (assured.reload null),             "assured pattern with boolean always return that"
    assert.is-not-ok assured.help,                   "pattern not in definition excluded from assured list"
    assert assured.watch "text.txt", "parsed pattern should be a last one (match *.txt)"
    assert (not (assured.watch "text.log")), "parsed pattern should be a last one (dont match *.log)"

  It "should assure options (2)", ->
    opt = new OptionHelper option-list

    parsed = {
      watch:  (is "none"),
      reload: false
      boolvar: false
      booltrue: true
    }
    assured = opt.assure parsed

    assured.watch  = OptionHelper.read-pattern assured.watch
    assured.reload = OptionHelper.read-pattern assured.reload

    assert.equal typeof assured.watch, "function",  "assured pattern should be a function"
    assert.equal assured.watch, parsed.watch,       "assured pattern with function should be a function itself"
    assert.equal typeof assured.reload, "function", "assured pattern should be a function"
    assert.equal typeof assured.boolvar, "boolean",  "assured boolean should be a boolean"

  It "should assure options set defaults", ->

    opt = new OptionHelper option-list
    assured = opt.assure {}

    assured.watch  = OptionHelper.read-pattern assured.watch
    assured.reload = OptionHelper.read-pattern assured.reload

    assert.equal  assured.port,  80,              "assured undefined number should be a default number"
    assert        assured.watch  "tes.watched",   "assured undefined pattern should be a default pattern"
    assert (not   assured.watch  "tes.watch"),    "assured undefined pattern should be a default pattern"
    assert        assured.reload "tes.reload",    "assured undefined pattern should be a default pattern"
    assert (not   assured.reload "tes.reloaded"), "assured undefined pattern should be a default pattern"
    assert.equal  typeof assured.boolvar,  "boolean",  "assured undefined boolean should be a boolean"
    assert.equal  typeof assured.booltrue, "boolean",  "assured undefined boolean should be a boolean"
    assert.equal  assured.boolvar,  false,  "assured undefined boolean should be a default boolean"
    assert.equal  assured.booltrue, true,   "assured undefined boolean should be a default boolean"


