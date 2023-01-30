import assert from "@dashkite/assert"
import {test, success} from "@dashkite/amen"
import print from "@dashkite/amen-console"

import { convert } from "@dashkite/bake"

import * as Headers from "../src"

import scenarios from "./scenarios"

do ->

  print await test "HTTP Headers", do ->

    for header, subscenarios of scenarios
      
      test header, do ({ parse, format } = {}) -> 

        { parse, format } = Headers[ header ]

        for scenario in subscenarios

          test scenario.name, [
            
            test "parse", -> 
              got = parse scenario.input
              assert.deepEqual scenario.expect, got
            
            test "format", ->
              console.log format scenario.expect
              assert.deepEqual scenario.expect,
                parse format scenario.expect

            test "JSON", ->
              parse JSON.parse JSON.stringify format scenario.expect

            test "base64", ->
              parse convert from: "base64", to: "utf8",
                convert from: "utf8", to: "base64", format scenario.expect

            test "JSON64", ->
              assert.deepEqual scenario.expect,
                parse JSON.parse convert from: "base64", to: "utf8",
                  convert from: "utf8", to: "base64",
                    JSON.stringify format scenario.expect
          ]

  process.exit if success then 0 else 1
