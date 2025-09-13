local api = require("search-and-replace.util.api")
local state = require("search-and-replace.state")

-- o methods
local main = {}

--- Opens the prompt for a vimgrep term to apply in the current project, then an other
--- prompt to replace by pattern.
---
--- @param scope string: identifier for logging purposes.
---@private
function main.search_and_replace_by_pattern(scope)
    state.init(state)

    state.create_buffer(state, scope, function(selection, replace)
        selection = selection or ""
        vim.cmd("vimgrep /" .. selection .. "/g **")
        if state.backup_qflist(state, scope) then
            api.replace(selection, replace)
        end
    end)

    state.create_windfooow(state, scope)
end

--- Replaces the word under cursor or current visual selection in the current project.
---
--- @param scope string: identifier for logging purposes.
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

    state.create_windfooow(state, scope)
end

--- Replaces the word under cursor or current visual selection using vim.lsp.buf.references().
---
--- @param scope string: identifier for logging purposes.
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

    state.create_windfooow(state, scope)
end

--- Restores the backup files of the last `replace_*` operation.
---
--- @param scope string: identifier for logging purposes.
---@private
function main.replace_undo(scope)
    state.restore_backup(state, scope)
end

return main
