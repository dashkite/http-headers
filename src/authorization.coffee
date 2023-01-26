import * as Parse from "@dashkite/parse"

import {
  sp
  ows
  authScheme
  authParam
  token68
  token
} from "./common"

# scheme + either an encoded value or a list of parameters
# credentials = auth-scheme [ 1*SP ( token68 / [ auth-param *( OWS ","
#  OWS auth-param ) ] ) ]
# ; as list
# ; https://www.rfc-editor.org/rfc/rfc9110.html#section-11.4
# credentials = auth-scheme [ 1*SP ( token68 / #auth-param ) ]

delim = Parse.all [
  ows
  Parse.text ","
  ows
]

credentials = Parse.pipe [
  Parse.all [
    authScheme
    Parse.pipe [
      Parse.all [
        Parse.skip Parse.many sp
        Parse.any [
          Parse.pipe [
            Parse.log Parse.list delim, authParam
            Parse.map ( parameters ) ->
              console.log parameters
              Object.fromEntries parameters
            Parse.tag "parameters"
          ]
          Parse.pipe [
            token68
            Parse.tag "token"
          ]
        ]
      ]
      Parse.first
    ]  
  ]
  Parse.merge
]

parse = Parse.parser credentials

parseToken = Parse.parser token

format = ({ scheme, parameters, token }) ->
  if parameters?
    result = []
    for key, value of parameters
      try
        parseToken value
      catch
        # JSON.stringify escapes quotes
        value = JSON.stringify value
      result.push "#{key}=#{value}"
    "#{ scheme } #{result.join ', '}"
  else if token?
    "#{ scheme } #{ token }"
  else
    throw new Error "invalid authorization header description"

export {
  parse
  format
}
