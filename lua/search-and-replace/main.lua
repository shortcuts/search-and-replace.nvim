local state = require("search-and-replace.state")

-- internal methods
local main = {}

--- Replace the word under cursor in the current project.
---
--- @param scope string: internal identifier for logging purposes.
---@private
function main.replace_in_project(scope)
    state.init(state)

    state.create_buffer(state, scope, function(word, replace)
        vim.cmd("vimgrep /\\<" .. word .. "\\>/gj **/*.*")
        state.backup_qflist(state, scope)
        vim.cmd("cfdo %s/\\<" .. word .. "\\>/" .. replace .. "/g")
        vim.cmd("cfdo update")
    end)

    state.create_window(state, scope, state.buffer)
end

--- Replace the word under cursor by references using vim.lsp.buf.references().
---
--- @param scope string: internal identifier for logging purposes.
---@private
function main.replace_by_references(scope)
    state.init(state)

    state.create_buffer(state, scope, function(word, replace)
        -- references is async so we need to store the window to restore focus
        local current_win = vim.api.nvim_get_current_win()

        vim.lsp.buf.references()

        vim.defer_fn(function()
            vim.api.nvim_set_current_win(current_win)
            state.backup_qflist(state, scope)
            vim.cmd("cfdo %s/\\<" .. word .. "\\>/" .. replace .. "/g")
            vim.cmd("cfdo update")
        end, 500)
    end)

    state.create_window(state, scope, state.buffer)
end

--- Undoes the last `replace_*` operation by restoring the saved backup.
---
--- @param scope string: internal identifier for logging purposes.
---@private
function main.undo(scope)
    state.restore_backup(state, scope)
end

return main
