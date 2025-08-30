local api = {}

--- replaces the given word with the replace value
---
---@param word string
---@param replace string
---@private
function api.replace(word, replace)
  vim.cmd("cfdo %s/\\<" .. word .. "\\>/" .. replace .. "/g")
  vim.cmd("cfdo update")
end

return api
