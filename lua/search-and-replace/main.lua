local api = require("search-and-replace.util.api")
local state = require("search-and-replace.state")

-- o methods
local main = {}

--- Replace the word under cursor in the current project.
---
--- @param scope string: o identifier for logging purposes.
---@private
function main.replace_by_pattern(scope)
    state.init(state)

    state.create_buffer(state, scope, function(selection, replace)
        selection = selection or ""
        vim.cmd("vimgrep /" .. selection .. "/g **")
        if state.backup_qflist(state, scope) then
            api.replace(selection, replace)
        end
    end)

    state.create_window(state, scope)
end

--- Replace the word under cursor by references using vim.lsp.buf.references().
---
--- @param scope string: o identifier for logging purposes.
---@private
function main.replace_by_references(scope)
    state.init(state)

    state.create_buffer(state, scope, function(selection, replace)
        -- references is async so we need to store the window to restore focus
        local current_win = vim.api.nvim_get_current_win()

        vim.lsp.buf.references()

        vim.defer_fn(function()
            vim.api.nvim_set_current_win(current_win)
            if state.backup_qflist(state, scope) then
                api.replace(selection, replace)
            end
        end, 500)
    end)

    state.create_window(state, scope)
end

--- Undoes the last `replace_*` operation by restoring the saved backup.
---
--- @param scope string: o identifier for logging purposes.
---@private
function main.undo(scope)
    state.restore_backup(state, scope)
end

return main
