import * as Parse from "@dashkite/parse"

#
# WWW-Authenticate = #challenge 
#
# ; defined using IETF ABNF as:
# WWW-Authenticate = [ challenge *( OWS "," OWS challenge ) ]
#
# ; challenge is identical to credentials...
# challenge = auth-scheme [ 1*SP ( token68 / [ auth-param *( OWS ","
#  OWS auth-param ) ] ) ]
#

import { commaDelimited, credentials as challenge } from "./common"
import { format as _format } from "./authorization"

parse = Parse.parser Parse.list commaDelimited, challenge

format = ( challenges ) -> 
  challenges
    .map _format
    .join ", "

export { parse, format }