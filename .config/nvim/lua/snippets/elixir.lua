local ls = require("luasnip")
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local d = ls.dynamic_node
local fmt = require("luasnip.extras.fmt").fmt

ls.add_snippets("elixir", {
  s({ trig = "re", desc = "Elixir regex literal" }, {
    t("~r/"), i(1, "pattern"), t("/"), i(2, "opts")
  }),
  s({ trig = "st", desc = "Elixir struct with @enforce_keys" }, fmt([[ 
    defmodule {} do
      @enforce_keys [{}]
      defstruct [
        {}
      ]
    end
  ]], {
    i(1, "ModuleName"),
    i(2, ":required1, :required2"),
    i(3, "optional1: nil, optional2: nil")
  })),
  s({ trig = "stf", desc = "Struct duplicate fields" }, fmt([[ 
    defmodule {} do
      @enforce_keys [{}]
      defstruct [{}]
    end
  ]], {
    i(1, "ModuleName"),
    i(2, ":field1, :field2"),
    d(3, function(args)
      return sn(nil, i(1, args[1][1]))
    end, { 2 })
  }))
}, { key = "elixir_core" })

ls.add_snippets("elixir", {
  s({ trig = "aoct(%d%d)", regTrig = true, desc = "AOC year/day test" }, fmt([[ 
    defmodule Aoc{}.Day{}Test do
      use ExUnit.Case
      alias Aoc{}.Day{}

      describe "part1/1" do
        test "{}" do
        end
      end

      describe "part2/1" do
        test "{}" do
        end
      end
    end
  ]], {
    i(1, "2016"),
    f(function(_, snip) return snip.captures[1] end, {}),
    i(2, "2016"),
    f(function(_, snip) return snip.captures[1] end, {}),
    i(3, "part1 description"),
    i(4, "part2 description")
  }))
}, { key = "elixir_aoc_test" })

ls.add_snippets("elixir", {
  s({ trig = "aoc(%d%d)", regTrig = true, desc = "AOC year/day module" }, fmt([[ 
    defmodule Aoc{}.Day{} do
      defp input do
        String.trim(File.read!("priv/inputs/day{}.txt"))
      end

      def part1(), do: part1(input())

      def part1(input) do
      end

      def part2(), do: part2(input())

      def part2(input) do
      end
    end
  ]], {
    i(1, "2016"),
    f(function(_, snip) return snip.captures[1] end, {}),
    f(function(_, snip) return snip.captures[1] end, {})
  }))
}, { key = "elixir_aoc_module" })
