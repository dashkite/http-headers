# HTTP Headers

*Parsers and formatters for HTTP Headers*

[![Hippocratic License HL3-CORE](https://img.shields.io/static/v1?label=Hippocratic%20License&message=HL3-CORE&labelColor=5e2751&color=bc8c3d)](https://firstdonoharm.dev/version/3/0/core.html)

## Install

Currently only available via local development.

## Usage

Each header provides a subpath import that exports a `parse` and `format` function.

```coffeescript
import * as Authorization from "@dashkite/http-headers/authorize"

authorization = 
	scheme: "rune"
  parameters: { rune, nonce }
  
assert.deepEqual authorization,
  Authorize.parse header,
    Authorize.format authorization
```

You may also import the header namespaces directly:

```coffee
import { Authorization, WWWAuthenticate } from "@dashkite/http-headers"
```

