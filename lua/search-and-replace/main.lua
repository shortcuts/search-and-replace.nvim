local state = require("search-and-replace.state")

-- internal methods
local main = {}

--- Replace the word under cursor in the current project.
---
--- @param scope string: internal identifier for logging purposes.
---@private
function main.replace_in_project(scope)
    state.create_buffer(state, scope, function(word)
        vim.cmd("vimgrep /\\<" .. word .. "\\>/gj **/*.*")
    end)

    state.create_window(state, scope, state.get_buffer(state))
end

--- Replace the word under cursor by references using vim.lsp.buf.references().
---
--- @param scope string: internal identifier for logging purposes.
---@private
function main.replace_by_references(scope)
    state.create_buffer(state, scope, function()
        vim.lsp.buf.references()
    end)

    state.create_window(state, scope, state.get_buffer(state))
end

return main
