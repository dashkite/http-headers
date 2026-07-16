# HTTP Headers API Reference

## Authorization

The `Authorization` module processes the HTTP `Authorization` request header. This header contains the credentials to authenticate a user agent with a server, often resolving a previous `401 Unauthorized` response. 

According to MDN Web Docs, the header typically consists of an authentication scheme (such as `Basic` or `Bearer`) followed by the credentials, which can be a single token or a list of parameters. 

### parse

$parse: text \to authorization$

Parses an authorization header string into a structured object. The resulting object always includes a `scheme` property and either a `token` string or a `parameters` object, depending on the authentication scheme's requirements.

```coffeescript
import { Authorization } from "@dashkite/http-headers"

# parsing a token-based credential
authorization = Authorization.parse "Bearer token123"
```

### format

$format: authorization \to text$

Formats a structured authorization object back into a valid HTTP header string. It handles serialization of parameters and ensures appropriate spacing between the scheme and the credentials.

```coffeescript
import { Authorization } from "@dashkite/http-headers"

header = Authorization.format 
  scheme: "Bearer"
  token: "token123"
```

## WWWAuthenticate

The `WWWAuthenticate` module processes the HTTP `WWW-Authenticate` response header. A server sends this header alongside a `401 Unauthorized` status to define the authentication method(s) that should be used to gain access to a resource.

This header specifies a "challenge" that dictates the required authentication scheme and provides additional parameters (like a `realm` or `nonce`) necessary for the client to construct a valid `Authorization` header.

### parse

$parse: text \to challenges$

Parses a `WWW-Authenticate` header string into an array of structured challenges. Each challenge object contains the authentication `scheme` and any provided `parameters`.

```coffeescript
import { WWWAuthenticate } from "@dashkite/http-headers"

challenges = WWWAuthenticate.parse 'Newauth realm="apps", type=1, title="Login to \\"apps\\""'
```

### format

$format: challenges \to text$

Formats an array of structured challenges into a compliant `WWW-Authenticate` header string, properly quoting and escaping parameters as required by HTTP specifications.

```coffeescript
import { WWWAuthenticate } from "@dashkite/http-headers"

header = WWWAuthenticate.format [
  { scheme: "Basic", parameters: { realm: "example" } }
]
```

## Link

The `Link` module processes the HTTP `Link` entity-header field. This header provides a standard means for serializing one or more links in HTTP responses, establishing relationships between the current document and external resources.

Drawing from Web Architecture concepts and the W3C, `Link` headers are frequently utilized for tasks such as specifying alternative representations, defining pagination (e.g., `next` or `previous` pages), or instructing the browser to preload critical assets.

### parse

$parse: text \to links$

Parses a `Link` header string into an array of link objects. Each object contains a `uri` property representing the target resource and an optional `parameters` object detailing the relationship (like the `rel` attribute).

```coffeescript
import { Link } from "@dashkite/http-headers"

links = Link.parse '<https://example.com>; rel="preload"'
```

### format

$format: links \to text$

Formats an array of link objects into a valid `Link` header string. It encloses URIs in angle brackets and correctly delimits relationships and their parameters.

```coffeescript
import { Link } from "@dashkite/http-headers"

header = Link.format [
  { uri: "https://example.com", parameters: { rel: "preload" } }
]
```

## Accept

The `Accept` module processes the HTTP `Accept` request header, which is exported directly from `@dashkite/media-type`. This header informs the server about the types of media that the client can understand.

This mechanism is the cornerstone of **proactive content negotiation**, enabling clients to request specific representations of a resource (e.g., asking for `application/json` instead of `text/html`) based on quality (`q`) factors.

### parse

$parse: text \to accept$

Parses an `Accept` header string into a structured representation of the requested media types and their respective weightings.

```coffeescript
import { Accept } from "@dashkite/http-headers"

accept = Accept.parse "text/html, application/xhtml+xml, application/xml;q=0.9"
```

### format

$format: accept \to text$

Formats an `Accept` structure into a standard, comma-separated `Accept` string, adhering to correct syntax for media ranges and parameters.

```coffeescript
import { Accept } from "@dashkite/http-headers"

header = Accept.format [
  { type: "text/html" }
  { type: "application/xml", parameters: { q: "0.9" } }
]
```

## ContentType

The `ContentType` module processes the HTTP `Content-Type` entity-header, which is exported directly from `@dashkite/media-type`. This header indicates the original media type of the resource being transmitted.

Understanding the `Content-Type` is vital for both clients and servers to correctly parse the HTTP message body payload, distinguishing between formats like URL-encoded form data, multipart forms, or JSON documents.

### parse

$parse: text \to content\_type$

Parses a `Content-Type` header string into a structured media type object containing the `type`, `subtype`, and any associated parameters (like `charset`).

```coffeescript
import { ContentType } from "@dashkite/http-headers"

contentType = ContentType.parse "application/json; charset=utf-8"
```

### format

$format: content\_type \to text$

Formats a structured media type object into a valid `Content-Type` string.

```coffeescript
import { ContentType } from "@dashkite/http-headers"

header = ContentType.format 
  type: "application/json"
  parameters: { charset: "utf-8" }
```
