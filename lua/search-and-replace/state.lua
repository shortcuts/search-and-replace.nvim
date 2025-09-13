local log = require("search-and-replace.util.log")
local api = require("search-and-replace.util.api")

local state = {}

---Initializes the state.
---
---@private
function state:init()
    self.reset(self)
    self.init_augroup(self)
    self.save(self)
end

---Sets the state to its original value.
---
---@private
function state:reset()
    self.buffer = nil
    self.window = nil
    self.augroup_name = "SearchAndReplace"

    self.save(self)
end

---Creates the augroup for the given
---
---@private
function state:init_augroup()
    vim.api.nvim_create_augroup(self.augroup_name, { clear = true })
end

---Saves the state in the global _G.SearchAndReplace.state object.
---
---@private
function state:save()
    _G.SearchAndReplace.state = self
end

---Saves the current undo state for every files of the quickfix list, in order to be able to restore it later.
---If nothing is found in the qflist, a log is emitted to hint the user know that there was no matches.
---
--- @param scope string
--- @return boolean
---@private
function state:backup_qflist(scope)
    self.backup = {}

    local qflist = vim.fn.getqflist({ items = 0 }).items

    if vim.fn.len(qflist) == 0 then
        log.debug(scope, "no match found for %s", self.selection)

        return false
    end

    log.debug(scope, "found %d items in qflist", vim.fn.len(qflist))

    local total = 0

    for _, item in ipairs(qflist) do
        local bufnr = item.bufnr
        if bufnr > 0 and vim.api.nvim_buf_is_valid(bufnr) then
            local name = vim.api.nvim_buf_get_name(bufnr)
            if name ~= "" and self.backup[name] == nil then
                local tmpfile = vim.fn.tempname() .. ".undo"
                vim.api.nvim_set_current_buf(bufnr)

                local seq = vim.fn.undotree().seq_cur or 0
                vim.cmd("silent! wundo " .. vim.fn.fnameescape(tmpfile))

                self.backup[name] = { bufnr = bufnr, tmp = tmpfile, seq = seq }
                -- keep for debug but way too spammy
                -- log.debug(scope, "saved undo for '%s' -> '%s' with seq '%d'", name, tmpfile, seq)

                total = total + 1
            end
        end
    end

    log.debug(scope, "stored '%d' items in backup", total)

    return true
end

---Restores the currently saved backup
---
--- @param scope string
---@private
function state:restore_backup(scope)
    if not self.backup then
        log.debug(scope, "no backup found")
        return
    end

    log.debug(scope, "restoring '%d' items", vim.fn.len(self.backup))

    for name, data in pairs(self.backup) do
        log.debug(scope, "restoring '%s'", name)

        if vim.api.nvim_buf_is_valid(data.bufnr) then
            vim.api.nvim_set_current_buf(data.bufnr)
            vim.cmd("silent! rundo " .. vim.fn.fnameescape(data.tmpfile))
            vim.cmd("silent! undo " .. data.seq)
            vim.cmd("update")
            log.debug(
                scope,
                "restored undo for '%s'",
                vim.api.nvim_buf_get_name(data.bufnr),
                data.seq
            )
        else
            log.debug(scope, "skipped '%s' (invalid buffer or missing file)", name)
        end
    end

    log.debug(scope, "restore done")
end

---Creates a buffer for a prompt.
---
--- @param scope string
--- @param cb function(string)
---@private
function state:create_buffer(scope, cb)
    self.buffer = vim.api.nvim_create_buf(false, true)

    vim.api.nvim_buf_set_option(self.buffer, "buftype", "prompt")
    vim.api.nvim_buf_set_option(self.buffer, "bufhidden", "wipe")
    vim.api.nvim_buf_set_option(self.buffer, "buflisted", false)
    vim.fn.prompt_setprompt(self.buffer, "> ")
    self.selection = api.get_visual_selection() or vim.fn.expand("<cword>")

    vim.api.nvim_create_autocmd({ "BufWinEnter" }, {
        callback = function()
            vim.schedule(function()
                if self.window and vim.api.nvim_win_is_valid(self.window) then
                    vim.api.nvim_set_current_win(self.window)
                end
            end)

            if not _G.SearchAndReplace.config.default_replace_prompt_to_normal_mode then
                vim.api.nvim_command("startinsert!")
            end

            if
                _G.SearchAndReplace.config.default_replace_prompt_to_selection
                and self.selection ~= ""
            then
                vim.api.nvim_buf_set_text(self.buffer, 0, 0, 0, 0, { self.selection })
            end
        end,
        group = self.augroup_name,
        desc = "Keeps track of the state after entering new windows",
    })

    vim.fn.prompt_setcallback(self.buffer, function(replace)
        self.cleanup(self, scope)

        cb(self.selection, replace)

        log.debug(scope, "replace with '%s' done", replace)
    end)

    log.debug(scope, "prompt buffer created, searching for '%s'", self.selection)

    self.save(self)
end

---Creates a window for the buffer.
---
--- @param scope string
---@private
function state:create_window(scope)
    self.window = vim.api.nvim_open_win(self.buffer, true, {
        style = "minimal",
        relative = "editor",
        width = math.floor(vim.o.columns / 3),
        height = 1,
        row = math.floor((vim.o.lines - 1) / 2),
        col = math.floor(vim.o.columns / 3),
        border = "rounded",
        title = string.format("Replacing '%s'", self.selection),
        title_pos = "center",
    })
    vim.keymap.set("i", "<Esc>", function()
        vim.api.nvim_win_close(self.window, true)
    end, { buffer = self.buffer })

    log.debug(scope, "window for buffer '%d' created", self.buffer)

    self.save(self)
end

---Closes the window.
---
--- @param scope string
---@private
function state:cleanup(scope)
    if self.buffer and vim.api.nvim_buf_is_valid(self.buffer) then
        log.debug(scope, "deleting buffer")
        vim.api.nvim_buf_delete(self.buffer, { force = true })
    end

    if self.window and vim.api.nvim_win_is_valid(self.window) then
        log.debug(scope, "closing window")

        vim.api.nvim_win_close(self.window, true)
    end

    pcall(vim.api.nvim_del_augroup_by_name, self.augroup_name)

    self.reset(self)

    if not _G.SearchAndReplace.config.default_replace_prompt_to_normal_mode then
        vim.api.nvim_command("stopinsert")
    end
end

return state
