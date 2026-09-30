local extra_paths = {
    vim.fn.stdpath("data") .. "/mason/bin",
    "/Applications/quarto/bin",
}

for _, path in ipairs(extra_paths) do
    if not vim.env.PATH:find(path, 1, true) then
        vim.env.PATH = path .. ":" .. vim.env.PATH
    end
end

require("amoore.remap")
require("amoore.lsp")
require("amoore.set")
