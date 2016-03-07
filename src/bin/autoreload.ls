require! {
  '../lib/option'   : {OptionHelper}
  '../index.js'     : Autoreload
  '../package.json' : pkg
}

###
# main function

do ->
  helper = new OptionHelper
  {parsed,unknown} = helper.parse!

  # show version
  if parsed.version
    console.log """
      #{pkg.name} v#{pkg.version}
    """

  # show usage
  if parsed.help
    prog = 'autoreload'

    console.log """
      Usage:
        #{prog} [options] [directory] [port]

      Options:
    """
    for {label,short,type,help,def,nocmd} in helper.options-list
      continue if nocmd
      param  = if (type isnt \boolean) then " <#{type}>" else ""
      shortp = if short? then ", -#{short}" else ""
      defp   = if def?   then "(default: #{def})" else ""
      defp   = if (type is <[ string regexp ]>) then "\"#{defp}\"" else defp

      console.log """
        --#{label} #{shortp} #{param} #{defp}
          #{help}
      """

  if parsed.help or parsed.version
    process.exit!

  if unknown.rest?.0?
    parsed.path = that

  if unknown.rest?.1?
    parsed.port = that * 1

  Autoreload parsed

