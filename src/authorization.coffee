import * as Parse from "@dashkite/parse"

sp = Parse.text " "
htab = Parse.re "\t"

# Optional whitespace
# OWS = *( SP / HTAB )
ows = Parse.optional Parse.any [ sp, htab ]

# Bad whitespace - should not generate, but must parse
# BWS = OWS
bws = ows

# visible (printing) characters
# https://www.rfc-editor.org/rfc/rfc5234#appendix-B.1
vchar = Parse.re /^[\x21-\x7E]/

# these are control characters, should be treated as opaque data
# https://www.rfc-editor.org/rfc/rfc9110.html#section-5.5-4
# obs-text = %x80-FF

obsText = Parse.re /^[\x80-\xFF]/

# escape sequence
# quoted-pair = "\" ( HTAB / SP / VCHAR / obs-text )
quotedPair = Parse.all [
  Parse.skip Parse.text "\\"
  Parse.any [
    htab
    sp
    vchar
    obsText
  ]
]

# what can go inside a quoted string
# qdtext = HTAB / SP / "!" / %x23-5B ; '#'-'['
#   / %x5D-7E ; ']'-'~'
#   / obs-text

qdtext = Parse.any [
  htab
  sp
  Parse.text "!"
  Parse.re /^[\x23-\x5B]/  # '#'-'['
  Parse.re /^[\x5d-\x7e]/  # ']'-'~'
  obsText
]

dquote = Parse.text '"'

# quoted-string = DQUOTE *( qdtext / quoted-pair ) DQUOTE
quotedString = Parse.pipe [
  Parse.all [
    Parse.skip dquote
    Parse.optional Parse.pipe [
      Parse.many Parse.any [
        qdtext
        quotedPair
      ]
      Parse.cat
    ]
    Parse.skip dquote
  ]
  Parse.first
]

# allowable token characters
# tchar = "!" / "#" / "$" / "%" / "&" / "'" / "*" / "+" / "-" / "." /
# "^" / "_" / "`" / "|" / "~" / DIGIT / ALPHA

tchar = Parse.re /^([!#$%&'*+-.^_`|~\d]|[a-zA-Z])/

# one or more tchars
# token = 1*tchar
token = Parse.pipe [
  Parse.many tchar
  Parse.cat
]

# limited for use with base64 etc
# token68 = 1*( ALPHA / DIGIT / "-" / "." / "_" / "~" / "+" / "/" )
# *"="
token68 = Parse.many Parse.re /^([a-zA-Z]|\d|[-._~+/])/

# auth-param = token BWS "=" BWS ( token / quoted-string )
authParam = Parse.all [
  token
  Parse.skip bws
  Parse.skip Parse.text "="
  Parse.skip bws
  Parse.any [
    token
    quotedString
  ]
]

# auth-scheme = token
authScheme = Parse.pipe [
  token
  Parse.tag "scheme"
]

# scheme + either an encoded value or a list of parameters
# credentials = auth-scheme [ 1*SP ( token68 / [ auth-param *( OWS ","
# OWS auth-param ) ] ) ]
credentials = Parse.pipe [
  Parse.all [
    authScheme
    Parse.pipe [
      Parse.all [
        Parse.skip Parse.re /^ +/
        Parse.any [
          Parse.pipe [
            Parse.all [
              authParam
              Parse.optional Parse.many Parse.all [
                Parse.skip ows
                Parse.skip Parse.text ","
                Parse.skip ows
                authParam
              ]
            ]
            Parse.map ( parameters ) ->
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

generate = ({ scheme, parameters, token }) ->
  if parameters?
    result = []
    for key, value of parameters
      try
        parseToken value
      catch
        # JSON.stringify escapes quotes
        value = JSON.stringify value
      result.push "#{key}=#{value}"
    "#{ scheme} #{result.join ', '}"


export {
  parse
  generate
}
