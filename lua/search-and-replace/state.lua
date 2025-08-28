local log = require("search-and-replace.util.log")

local state = { buffer = nil, window = nil, path = nil }

---Sets the state to its original value.
---
---@private
function state:init()
    self.buffer = nil
    self.path = nil
    self.window = nil
end

---Saves the state in the global _G.SearchAndReplace.state object.
---
---@private
function state:save()
    _G.SearchAndReplace.state = self
end

---Creates a buffer for a prompt.
---
--- @param scope string
--- @param cb function(string)
---@private
function state:create_buffer(scope, cb)
    self.buffer = vim.api.nvim_create_buf(false, true)

    vim.api.nvim_buf_set_option(self.buffer, "buftype", "prompt")
    vim.fn.prompt_setprompt(self.buffer, "Replace with: ")

    vim.fn.prompt_setcallback(self.buffer, function(text)
        self.cleanup(self, scope)
        local word = vim.fn.expand("<cword>")
        cb(word)
        vim.cmd("cfdo %s/\\<" .. word .. "\\>/" .. text .. "/g")
        vim.cmd("cfdo update")

        log.debug(scope, "replace done")
    end)

    vim.keymap.set({ "i", "n" }, "<Esc>", function()
        log.debug(scope, "requested closing")
        self.cleanup(self, scope)
    end, { buffer = self.buffer })

    log.debug(scope, "prompt buffer created")

    self.save(self)
end

---Gets the buffer id.
---
---@return number: the buffer id.
---@private
function state:get_buffer()
    return self.buffer
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
    if self.window and vim.api.nvim_win_is_valid(self.window) then
        log.debug(scope, "closing window")

        vim.api.nvim_win_close(self.window, true)
    end

    if self.buffer and vim.api.nvim_buf_is_valid(self.buffer) then
        log.debug(scope, "deleting buffer")
        vim.api.nvim_buf_delete(self.buffer, { force = true })
    end

    self.window = nil
    self.buffer = nil
end

return state
