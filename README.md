# @dashkite/http-headers

*Parsers and formatters for HTTP Headers*

[![Hippocratic License HL3-CORE](https://img.shields.io/static/v1?label=Hippocratic%20License&message=HL3-CORE&labelColor=5e2751&color=bc8c3d)](https://firstdonoharm.dev/version/3/0/core.html)

The `@dashkite/http-headers` package provides robust parsers and formatters for a variety of common HTTP headers. It leverages a parser combinator approach to ensure strict adherence to HTTP header specifications while providing a simple, predictable interface for developers.

## Features

- Parses and formats complex HTTP headers accurately.
- Supports `Authorization`, `WWW-Authenticate`, `Link`, `Accept`, and `Content-Type` headers.
- Employs parser combinators for reliable and maintainable text processing.
- Handles edge cases such as quoted strings, whitespace, and base64 encoded tokens seamlessly.
- Exposes a consistent `parse` and `format` API across all supported header types.

## Installation

```bash
pnpm install @dashkite/http-headers
```

## Usage

Each header module provides an intuitive interface for converting between string representations and structured objects.

```coffeescript
import { Authorization } from "@dashkite/http-headers"

# define a structured authorization object
authorization = 
  scheme: "bearer"
  token: "xyz123abc987"

# format it into an HTTP header string
headerString = Authorization.format authorization

# parse an incoming header string back into a structured object
parsedAuthorization = Authorization.parse headerString
```

## Other Resources

- [Reference Documentation](docs/reference.md)
- [Usage Guides](docs/recipes.md)
- [Technical Notes](docs/technical-notes.md)
- [Testing](docs/testing.md)
