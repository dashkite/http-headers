import * as Scan from "@dashkite/scan"
import * as Parse from "@dashkite/parse"

import { token } from "./common"

$ = 
  space: " "
  tab: "\t"
  assign: "="
  escape: "\\"
  token: /^[!#$%&'*+\-\.^_`|~\da-zA-Z]+/
  comma: ","

unquote = ( state ) ->
  if ( state.current.startsWith '"' ) && ( state.current.endsWith '"' )
    state.current = state.current[1...-1]
  state

finish = ( state ) ->
  result = {}
  for item in state.data.output
    if item.scheme?
      result.scheme = item.scheme
    else if item.token?
      result.token = item.token
    else if item.name?
      parameter = item.name
    else if item.value?
      result.parameters ?= {}
      result.parameters[ parameter ] = item.value
  result

scan = Scan.make "start",

  start:

    default: Scan.pipe [
      Scan.append
      Scan.poke "scheme"
    ]

    [ $.space ]: Scan.skip
    [ $.tab ]: Scan.skip

  scheme:

    default: Scan.append
  
    [ $.space ]: wsScheme = Scan.pipe [
      Scan.skip
      Scan.trim
      Scan.match $.token
      Scan.lower
      Scan.tag "scheme"
      Scan.save "output"
      Scan.clear
      Scan.poke "token"
    ]
    [ $.tab ]: wsScheme

  token:

    default: Scan.append

    [ $.escape ]: Scan.pipe [
      Scan.skip
      Scan.push "escape"
    ]

    [ $.assign ]: name = Scan.pipe [
      Scan.skip
      Scan.poke "maybe-value"
    ]

    end: endToken = Scan.pipe [
      Scan.skip
      Scan.tag "token"
      Scan.save "output"
      Scan.clear
      Scan.pop
      finish
    ]

  "maybe-value":
  
    default: Scan.pipe [
      Scan.buffer
      Scan.trim
      Scan.match $.token
      Scan.lower
      Scan.tag "name"
      Scan.save "output"
      Scan.clear
      Scan.unbuffer Scan.append
      Scan.poke "value"
    ]

    [ $.assign ]: Scan.pipe [
      Scan.skip
      Scan.append "=="
      Scan.poke "token"
    ]

    end: endToken
  
  value:

    default: Scan.append

    [ $.space ]: wsValue = Scan.pipe [
      Scan.skip
      unquote
      Scan.match $.token
      Scan.tag "value"
      Scan.save "output"
      Scan.clear
      Scan.poke "parameter"
    ]
    [ $.tab ]: wsValue

    [ $.escape ]: Scan.pipe [
      Scan.skip
      Scan.push "escape"
    ]

    [ $.comma ]: Scan.pipe [
      Scan.skip
      unquote
      Scan.match $.token
      Scan.tag "value"
      Scan.save "output"
      Scan.clear
      Scan.poke "parameter"
    ]

    end: Scan.pipe [
      Scan.skip
      unquote
      Scan.match $.token
      Scan.tag "value"
      Scan.save "output"
      Scan.clear
      Scan.pop
      finish
    ]

  parameter:

    default: Scan.pipe [
      Scan.append
      Scan.poke "name"
    ]

    [ $.space ]: Scan.skip
    [ $.tab ]: Scan.skip

  name:

    default: Scan.append

    [ $.assign]: name

  escape:

    default: Scan.pipe [
      Scan.append
      Scan.pop
    ]

parseToken = Parse.parser token

parse = ( text ) ->
  scan text

format = ({ scheme, parameters, token }) ->
  if scheme? && parameters?
    result = []
    for key, value of parameters
      try
        parseToken value
      catch
        # JSON.stringify escapes quotes
        value = JSON.stringify value
      result.push "#{key}=#{value}"
    "#{ scheme } #{result.join ', '}"
  else if scheme? && token?
    "#{ scheme } #{ token }"
  else if scheme?
    scheme
  else
    throw new Error "invalid authorization header description"

export {
  parse
  format
}
