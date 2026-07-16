# Technical Notes

### RFC Standard Adherence

The implementation details of this library are strictly guided by the authoritative internet standards governing HTTP. The parser combinators are designed to directly reflect the ABNF grammar rules specified in these documents:

- **RFC 9110 (HTTP Semantics)**: Guides the core rules for `Authorization`, `WWW-Authenticate`, and foundational header parsing semantics (like quoted strings and whitespace handling).
- **RFC 9111 (HTTP Caching) & RFC 9112 (HTTP/1.1)**: Inform general HTTP parsing context.
- **RFC 8288 (Web Linking)**: Governs the implementation of the `Link` header.
- **RFC 2045 / RFC 2046 (MIME)**: Guides the underlying media type parsing for `Accept` and `Content-Type`.

By anchoring the logic directly to these RFCs, the parsers maintain absolute accuracy and avoid the pitfalls of naive string splitting or regular expression approximations.

### Managed Complexity

When implementing the REST architectural pattern, HTTP headers are utilized to express vital constraints on request and response representations. While these headers are extremely information-dense and feature specialized, arcane DSL encodings optimized for transfer across the wire, they are fundamentally difficult to manipulate manually. 

A prime example is media type negotiation; it encapsulates immense complexity regarding priorities and parameters. However, developers need a way to access and modify this information programmatically without compromising accuracy or violating protocol syntax. 

The standards encoded in `@dashkite/http-headers` serve to completely manage all of this complexity at the foundation layer. Much like our approach with Sky API descriptions and locators, safely encapsulating this complexity frees higher-level abstract constructions from needing to reinvent HTTP serialization rules, ensuring that architectural constraints are expressed reliably across the entire system.

### Parser Combinators

The parsing logic in this repository utilizes parser combinators provided by `@dashkite/parse` and `@dashkite/scan`. This approach allows complex HTTP header grammars to be broken down into small, composable parsing functions. This design makes it significantly easier to maintain the parser logic, as new rules or edge cases can be addressed by adjusting specific combinators rather than refactoring a monolithic regular expression. 

### External Parsing Dependencies

The `Accept` and `ContentType` headers are not parsed internally within this repository. Because media type and content negotiation are complex subjects with specific RFC requirements, their implementation is deferred to the `@dashkite/media-type` package. This library exports them for convenience, maintaining a unified surface area for all header parsing needs.
