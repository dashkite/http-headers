import assert from "@dashkite/assert"
import {test, success} from "@dashkite/amen"
import print from "@dashkite/amen-console"

import * as Headers from "../src"

import scenarios from "./scenarios"

do ->

  print await test "HTTP Headers", do ->

    for header, { parse, format } of scenarios

      test header, [

        test "parse", do ->

          for scenario in parse

            test scenario.name, ->
              # assert.equal scenario.expect
              #   Headers[ header ].parse scenario.input
              console.log result = Headers[ header ].parse scenario.input
              console.log Headers[ header ].generate result
      ]

  process.exit if success then 0 else 1
