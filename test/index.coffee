import assert from "@dashkite/assert"
import {test, success} from "@dashkite/amen"
import print from "@dashkite/amen-console"

import * as Time from "@dashkite/joy/time"

import { convert } from "@dashkite/bake"
import { expand } from "@dashkite/polaris"

import * as Headers from "../src"

import scenarios from "./scenarios"

# quick and dirty way to get rid of undefined
# TODO should equality work for undefined?
compact = ( value ) -> JSON.parse JSON.stringify value

do ->

  print await test "HTTP Headers", do ->

    for header, subscenarios of scenarios
      
      test header, do ({ parse, format } = {}) -> 

        { parse, format } = Headers[ header ]

        for scenario in subscenarios

          if header == "Link"

            test scenario.name, [
              
              test "parse", -> 
                got = compact parse scenario.input
                assert.deepEqual scenario.expect, got
              
              test "format", ->
                assert.deepEqual scenario.expect,
                  compact parse format scenario.expect
            ]

          else

            test scenario.name, [
              
              test "parse", -> 
                got = compact parse scenario.input
                assert.deepEqual scenario.expect, got
              
              test "format", ->
                assert.deepEqual scenario.expect,
                  compact parse format scenario.expect

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

              # simulating the full process for encoding multiple
              # credentials and decoding on the client
              test "credentials", ->
                assert.deepEqual scenario.expect,
                  parse JSON.parse convert 
                    from: "base64"
                    to: "utf8"
                    convert 
                      from: "utf8"
                      to: "base64",
                      JSON.stringify expand "${ credential }",
                        credential: format scenario.expect

              test "benchmark", ->
                expect = structuredClone scenario.expect
                if expect.token?
                  expect.token = expect.token.repeat 1000
                else
                  for key, value of expect.parameters
                    expect.parameters[ key ] = value.repeat 1000
                input = format expect
                ms = Time.benchmark ->
                  compact parse input
                console.log ms


          ]

  process.exit if success then 0 else 1
