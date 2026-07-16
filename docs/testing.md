# Testing

The `@dashkite/http-headers` package relies on `@dashkite/amen` to provide comprehensive test coverage.

The general approach to testing involves defining numerous scenarios for each header type. Each scenario typically provides an input string and an expected structured object. The test runner iterates over these scenarios and validates several critical properties:

1. **Parsing**: The raw input parses into a structure that strictly matches the expected output.
2. **Formatting**: Formatting the expected output structure produces a string that can be parsed back into the exact same structure (round-trip verification).
3. **Data Integrity**: Edge cases involving encoding formats, such as `base64` and JSON, correctly survive transformations between string and object forms.
4. **Performance**: A benchmark test is occasionally run to measure the time required to parse significantly large tokens (e.g., thousands of characters in length), ensuring the parser combinators do not suffer from catastrophic backtracking or severe performance degradation.

### Running Tests

To run the test suite, use the `genie` test command:

```bash
npx genie test
```
