-- You can use this loaded variable to enable conditional parts of your plugin.
if _G.SearchAndReplaceLoaded then
    return
end

_G.SearchAndReplaceLoaded = true

vim.api.nvim_create_user_command("ReplaceByPattern", function()
    require("search-and-replace").replace_by_pattern()
end, { range = true })

vim.api.nvim_create_user_command("ReplaceByReferences", function()
    require("search-and-replace").replace_by_references()
end, { range = true })

vim.api.nvim_create_user_command("ReplaceUndo", function()
    require("search-and-replace").undo()
end, {})
