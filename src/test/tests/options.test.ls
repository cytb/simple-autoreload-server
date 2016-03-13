

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

    assert.equals parsed.port.length,   1,           "port should be 1 element array of string"
    assert.equals parsed.port.0,        "1000",      "port should be parsed properly"
    assert.equals parsed.watch.length,  1,           "pattern should be 1elem"
    assert.equals parsed.watch.0,       "**",        "pattern should be parsed as a string"
    assert.equals typeof parsed.test,   "undefined", "unknown flag should be excluded from parsed"
    refute.equals typeof unknown.full.test,"undefined", "unknown flag should be included in unknown"
    refute        unknown.full.test[0],                 "negated flag should be false"

  It "should assure options", ->
    opt = new OptionHelper option-list

    {parsed,unknown} = opt.parse <[
      --port=1000 --watch *.log --port=100 --watch *.txt --reload --no-help
    ]>

    assured = opt.assure parsed

    assert.equals typeof assured.port, "number",     "port should be a number"
    assert.equals assured.port, 100,                 "port should be a last option"

    assured.watch  = OptionHelper.read-pattern assured.watch
    assured.reload = OptionHelper.read-pattern assured.reload

    assert.equals typeof assured.watch, "function",  "assured pattern should be a function"
    assert.equals typeof assured.reload, "function", "assured pattern should be a function"
    assert        (assured.reload null),             "assured pattern with boolean always return that"
    refute        assured.help,                      "pattern not in definition excluded from assured list"
    assert assured.watch "text.txt", "parsed pattern should be a last one (match *.txt)"
    refute assured.watch "text.log", "parsed pattern should be a last one (dont match *.log)"

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

    assert.equals typeof assured.watch, "function",  "assured pattern should be a function"
    assert.equals assured.watch, parsed.watch,       "assured pattern with function should be a function itself"
    assert.equals typeof assured.reload, "function", "assured pattern should be a function"
    assert.equals typeof assured.boolvar, "boolean",  "assured boolean should be a boolean"

  It "should assure options set defaults", ->

    opt = new OptionHelper option-list
    assured = opt.assure {}

    assured.watch  = OptionHelper.read-pattern assured.watch
    assured.reload = OptionHelper.read-pattern assured.reload

    assert.equals assured.port,  80,             "assured undefined number should be a default number"
    assert        assured.watch  "tes.watched",  "assured undefined pattern should be a default pattern"
    refute        assured.watch  "tes.watch",    "assured undefined pattern should be a default pattern"
    assert        assured.reload "tes.reload",   "assured undefined pattern should be a default pattern"
    refute        assured.reload "tes.reloaded", "assured undefined pattern should be a default pattern"
    assert.equals typeof assured.boolvar,  "boolean",  "assured undefined boolean should be a boolean"
    assert.equals typeof assured.booltrue, "boolean",  "assured undefined boolean should be a boolean"
    assert.equals assured.boolvar,  false,  "assured undefined boolean should be a default boolean"
    assert.equals assured.booltrue, true,   "assured undefined boolean should be a default boolean"


