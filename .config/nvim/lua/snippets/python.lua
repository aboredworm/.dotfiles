local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local fmt = require("luasnip.extras.fmt").fmt

ls.add_snippets("python", {
  s({ trig = "dgd", desc = "Google-style docstring" }, fmt([["""
{}

Args:
    {}: {}
    {}: {}

Returns:
    {}
"""
]], {
    i(1, "Summary."),
    i(2, "param1"), i(3, "Description."),
    i(4, "param2"), i(5, "Description."),
    i(6, "Return description.")
  }))
}, { key = "python_docstring" })

