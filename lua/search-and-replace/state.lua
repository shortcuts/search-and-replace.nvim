local log = require("search-and-replace.util.log")

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
---
--- @param scope string
---@private
function state:backup_qflist(scope)
    self.backup = {}

    local qflist = vim.fn.getqflist({ items = 0 }).items

    log.debug(scope, "found %d items in qflist", vim.fn.len(qflist))

    for _, item in ipairs(qflist) do
        local buf = vim.fn.bufnr(item.bufnr)
        if buf > 0 and vim.api.nvim_buf_is_valid(buf) then
            if vim.api.nvim_buf_get_name(buf) ~= "" and self.backup[buf] == nil then
                local tmpfile = vim.fn.tempname() .. ".undo"
                vim.api.nvim_set_current_buf(buf)
                vim.cmd("silent! wundo " .. tmpfile)
                self.backup[buf] = tmpfile
            end
        end
    end

    log.debug(scope, "stored %d items in backup", vim.fn.len(self.backup))
end

---Restores the currently saved backup
---
--- @param scope string
---@private
function state:restore_backup(scope)
    log.debug(scope, "found %d items in backup", vim.fn.len(self.backup))

    for bufnr, tmpfile in pairs(self.backup) do
        vim.print(tmpfile)
        vim.print(bufnr)
        if vim.fn.filereadable(tmpfile) == 1 and vim.api.nvim_buf_is_valid(bufnr) then
            vim.print("yes")
            vim.api.nvim_set_current_buf(bufnr)
            vim.cmd("sil rundo " .. vim.fn.fnameescape(tmpfile))
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

    vim.api.nvim_create_autocmd({ "BufWinEnter" }, {
        callback = function()
            vim.schedule(function()
                if self.window and vim.api.nvim_win_is_valid(self.window) then
                    vim.api.nvim_set_current_win(self.window)
                end
            end)

            vim.api.nvim_command("startinsert!")
        end,
        group = self.augroup_name,
        desc = "Keeps track of the state after entering new windows",
    })

    vim.fn.prompt_setcallback(self.buffer, function(replace)
        self.cleanup(self, scope)

        cb(vim.fn.expand("<cword>"), replace)

        log.debug(scope, "replace done")
    end)

    vim.keymap.set({ "i", "n" }, "<Esc>", function()
        log.debug(scope, "requested closing")
        self.cleanup(self, scope)
    end, { buffer = self.buffer })

    log.debug(scope, "prompt buffer created")

    self.save(self)
end

---Creates a window for the buffer.
---
--- @param scope string
--- @param buffer number: the buffer id.
---@private
function state:create_window(scope, buffer)
    self.window = vim.api.nvim_open_win(buffer, true, {
        style = "minimal",
        relative = "editor",
        width = 40,
        height = 1,
        row = math.floor((vim.o.lines - 5) / 2),
        col = math.floor((vim.o.columns - 40) / 2),
        border = "rounded",
        title = "Replace with:",
        title_pos = "center",
    })
    vim.keymap.set("i", "<Esc>", function()
        vim.api.nvim_win_close(self.window, true)
    end, { buffer = buffer })

    log.debug(scope, "window for buffer %d created", buffer)

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

    vim.api.nvim_command("stopinsert")
end

return state
