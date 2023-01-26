import * as Parse from "@dashkite/parse"

sp = Parse.text " "
htab = Parse.re "\t"

export { sp, htab }

# Optional whitespace
# OWS = *( SP / HTAB )
ows = Parse.optional Parse.any [ sp, htab ]

# Bad whitespace - should not generate, but must parse
# BWS = OWS
bws = ows

export { ows, bws }

# visible (printing) characters
# https://www.rfc-editor.org/rfc/rfc5234#appendix-B.1
vchar = Parse.re /^[\x21-\x7E]/

export { vchar }

# these are control characters, should be treated as opaque data
# https://www.rfc-editor.org/rfc/rfc9110.html#section-5.5-4
# obs-text = %x80-FF

obsText = Parse.re /^[\x80-\xFF]/

export { obsText }

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

export { quotedPair }

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

export { qdtext }

dquote = Parse.text '"'

export { dquote }

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

export { quotedString }

# allowable token characters
# tchar = "!" / "#" / "$" / "%" / "&" / "'" / "*" / "+" / "-" / "." /
# "^" / "_" / "`" / "|" / "~" / DIGIT / ALPHA

tchar = Parse.re /^([!#$%&'*+-.^_`|~\d]|[a-zA-Z])/

export { tchar }

# one or more tchars
# token = 1*tchar
token = Parse.pipe [
  Parse.many tchar
  Parse.cat
]

export { token }

# limited for use with base64 etc
# token68 = 1*( ALPHA / DIGIT / "-" / "." / "_" / "~" / "+" / "/" )
# *"="
token68 = Parse.pipe [
  Parse.all [
    Parse.pipe [
      Parse.many Parse.re /^([a-zA-Z]|\d|[-._~+/])/
      Parse.cat
    ]
    Parse.re /^=*/
  ]
  Parse.cat
]

export { token68 }

# auth-param = token BWS "=" BWS ( token / quoted-string )
authParam = Parse.log Parse.all [
  token
  Parse.skip bws
  Parse.skip Parse.text "="
  Parse.skip bws
  Parse.any [
    token
    quotedString
  ]
]

export { authParam }

# auth-scheme = token
authScheme = Parse.pipe [
  token
  Parse.tag "scheme"
]

export { authScheme }
