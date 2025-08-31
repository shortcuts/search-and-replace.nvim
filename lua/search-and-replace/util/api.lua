local api = {}

--- replaces the given word with the replace value
---
---@param selection string
---@param replace string
---@private
function api.replace(selection, replace)
    selection = selection or ""
    vim.print("cfdo %s/" .. selection .. "/" .. replace .. "/g")
    vim.cmd("cfdo %s/" .. selection .. "/" .. replace .. "/g")
    vim.cmd("cfdo update")
end

--- gets the current selection (if any)
---
---@private
function api.get_visual_selection()
    local _, line_start, char_start = unpack(vim.fn.getpos("'<"))
    local _, line_end, char_end = unpack(vim.fn.getpos("'>"))

    -- no support for multi line yet
    if line_start ~= line_end then
        return nil
    end

    -- no selection
    if char_start == char_end then
        return nil
    end

    -- shouldn't happen but in case it does
    local lines = vim.fn.getline(line_start, line_end)
    if #lines ~= 1 then
        return nil
    end

    return string.sub(lines[1], char_start, char_end)
end

return api
