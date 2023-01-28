import * as Parse from "@dashkite/parse"

import {
  token
  credentials
} from "./common"

parse = Parse.parser credentials

parseToken = Parse.parser token

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
