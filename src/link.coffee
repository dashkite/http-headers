import * as Parse from "@dashkite/parse"

import {
  ows
  parameterList
  uriReference
  commaDelimited
  token
} from "./common"

#   Link       = #link-value
#   link-value = "<" URI-Reference ">" *( OWS ";" OWS link-param )
#   link-param = token BWS [ "=" BWS ( token / quoted-string ) ]

link = Parse.pipe [
  Parse.all [
    Parse.pipe [
      Parse.between [ "<", ">" ], uriReference
      Parse.tag "url"
    ]
    Parse.optional Parse.pipe [
      Parse.all [
        Parse.skip ows
        parameterList
      ]
      Parse.first
      Parse.tag "parameters"
    ]
  ]
  Parse.merge
]

links = Parse.list commaDelimited, link

parse = Parse.parser links

# adapted from https://www.rfc-editor.org/rfc/rfc3986.html#section-5.3
formatURI = ({ scheme, authority, path, query, fragment }) ->
  result = ""
  if scheme?
    result += "#{ scheme }:"
  if authority?
    result += "//#{ authority }"
  result += path
  if query?
    result += "?#{ query }"
  if fragment?
    result += "##{ fragment }"
  result

parseToken = Parse.parser token

format = ( links ) ->
  result = do ->
    for { url, parameters } in links
      if url.scheme?
        url = formatURI url
      if parameters?
        _result = do ->
          for key, value of parameters
            try
              parseToken value
              "#{ key }=#{ value }"
            catch
              "#{ key }=#{ JSON.stringify value }"
        "<#{ url }> #{_result.join '; '}"
      else
        "<#{ url }>"
  result.join ", "

export {
  parse
  format
}