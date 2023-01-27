import assert from "@dashkite/assert"
import {test, success} from "@dashkite/amen"
import print from "@dashkite/amen-console"

import * as Headers from "../src"

import scenarios from "./scenarios"

do ->

  print await test "HTTP Headers", do ->

    for header, subscenarios of scenarios
      
      test header, do ({ parse, format } = {}) -> 

        { parse, format } = Headers[ header ]

        for scenario in subscenarios

          got = parse scenario.input

          test scenario.name, [
            
            test "parse", ->            
              assert.deepEqual scenario.expect, got
            
            test "format", ->
              assert.deepEqual scenario.expect,
                parse format got

          ]

  process.exit if success then 0 else 1
