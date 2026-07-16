# Usage Guides

## Determining Content Type

This guide demonstrates how to parse an incoming `Content-Type` header to determine the format of a request body, such as whether a client is sending JSON data or URL-encoded forms.

The `@dashkite/http-headers` package enables this task via the `ContentType.parse` function. It safely abstracts away additional media parameters (like `charset` or `boundary`), allowing the developer to focus purely on the `type` and `subtype` without resorting to error-prone string splitting.

```coffeescript
import { ContentType } from "@dashkite/http-headers"

# implementation of request handling goes here
# request = receiveIncomingRequest()
headerValue = "application/json; charset=utf-8"

# parse the header to obtain the media type structure
contentType = ContentType.parse headerValue

# implementation of body parsing logic goes here
# if contentType.type == "application" and contentType.subtype == "json"
#   body = JSON.parse request.body
```

### Algorithm Explanation

1. The developer obtains the raw text of the `Content-Type` header from the incoming HTTP request.
2. The developer passes this string to `ContentType.parse`.
3. The parser separates the primary media type (e.g., `application/json`) from any appended parameters (e.g., `charset=utf-8`).
4. The developer receives a structured object and inspects the `type` and `subtype` properties to route the request body to the appropriate internal parser.

## Formatting a Link Header for Pagination

This guide demonstrates how to dynamically generate a `Link` header to instruct clients about related resources, commonly used for API pagination.

The software enables this by providing a `Link.format` function. The developer constructs an array of plain objects containing URIs and relationships, and the formatter safely serializes them into valid HTTP header syntax, enclosing URIs in angle brackets and appending parameters correctly.

```coffeescript
import { Link } from "@dashkite/http-headers"

# define the relationship and location of resources
links = [
  { uri: "/api/items?page=2", parameters: { rel: "next" } }
  { uri: "/api/items?page=5", parameters: { rel: "last" } }
]

# format the relationships into a valid header string
headerValue = Link.format links

# implementation of outgoing response dispatch goes here
# sendResponse "Link", headerValue
```

### Algorithm Explanation

1. The developer constructs an array of objects. Each object contains a `uri` property and a `parameters` object indicating relationships, like `rel`.
2. The developer passes this array to `Link.format`.
3. The formatter processes each link, enclosing the URI in angle brackets (`< >`) and appending the serialized parameters separated by semicolons.
4. The formatter joins multiple links with commas, returning the final string for the developer to attach to the HTTP response.

## Parsing an Authorization Header

This guide demonstrates how to parse an incoming HTTP `Authorization` header to extract the authentication scheme and credentials for validation.

The `@dashkite/http-headers` package streamlines this through the `Authorization.parse` function. This function abstracts away the intricacies of whitespace and token boundaries, providing the developer with a clean, structured object containing the scheme and the token (or parameters) to validate.

```coffeescript
import { Authorization } from "@dashkite/http-headers"

# implementation of request handling and header extraction goes here
# request = receiveIncomingRequest()
headerValue = "Bearer x1y2z3a4b5c6"

# parse the header to obtain scheme and credentials
credentials = Authorization.parse headerValue

# implementation of credential verification goes here
# verify credentials.scheme, credentials.token
```

### Algorithm Explanation

1. The developer obtains the raw text of the `Authorization` header from the incoming request.
2. The developer passes the raw string to `Authorization.parse`.
3. The parser breaks down the text, identifying the scheme (e.g., `Bearer`) and extracting either the subsequent base64 token or key-value parameters.
4. The developer receives a plain object containing these properties and proceeds to verify them against their security rules.

## Negotiating Response Formats

This guide demonstrates how to parse a complex `Accept` header to implement proactive content negotiation, allowing a server to determine the best response format for a client.

The software enables this task using the `Accept.parse` function. Instead of manually parsing a comma-separated list of media ranges and quality (`q`) factors, the developer receives an array of structured media type objects that can be easily sorted and matched against the server's supported formats.

```coffeescript
import { Accept } from "@dashkite/http-headers"

# implementation of request handling goes here
headerValue = "application/json, text/html;q=0.9, */*;q=0.8"

# parse the header to obtain an array of acceptable media types
acceptedTypes = Accept.parse headerValue

# implementation of content negotiation goes here
# bestFormat = determineBestFormat acceptedTypes, [ "application/json", "application/xml" ]
```

### Algorithm Explanation

1. The developer retrieves the `Accept` header string from the client's request.
2. The developer passes the string to `Accept.parse`.
3. The parser splits the string by commas, evaluates each media range, and isolates any associated parameters (such as the `q` weight).
4. The developer receives an array of objects representing the requested formats and uses this array to compute the most suitable representation to return.

## Constructing a WWW-Authenticate Challenge

This guide demonstrates how to build a complex `WWW-Authenticate` header to reject an unauthorized request and instruct the client on exactly how to authenticate.

The software enables this via the `WWWAuthenticate.format` function. Building challenge headers manually is error-prone due to the strict quoting and escaping rules for parameters. The formatter manages these arcane string manipulation rules automatically, converting an array of challenge objects into a spec-compliant header.

```coffeescript
import { WWWAuthenticate } from "@dashkite/http-headers"

# define the required authentication challenges
challenges = [
  { scheme: "Newauth", parameters: { realm: "apps", type: 1, title: 'Login to "apps"' } }
  { scheme: "Basic", parameters: { realm: "simple" } }
]

# format the challenges into a compliant header string
headerValue = WWWAuthenticate.format challenges

# implementation of 401 Unauthorized response dispatch goes here
# sendResponse "WWW-Authenticate", headerValue, status: 401
```

### Algorithm Explanation

1. The developer creates an array of challenge objects, specifying the required `scheme` (e.g., `Basic` or `Newauth`) and a dictionary of `parameters` (like the `realm`).
2. The developer passes the array to `WWWAuthenticate.format`.
3. The formatter iterates through the challenges, serializing the parameters and applying HTTP quoting/escaping rules where values contain spaces or special characters.
4. The formatter joins the challenges with commas and returns the finalized string, which the developer attaches to a `401 Unauthorized` HTTP response.
