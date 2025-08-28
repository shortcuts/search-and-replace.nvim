-- You can use this loaded variable to enable conditional parts of your plugin.
if _G.SearchAndReplaceLoaded then
    return
end

_G.SearchAndReplaceLoaded = true

vim.api.nvim_create_user_command("SearchAndReplaceInProject", function()
    require("search-and-replace").replace_in_project()
end, {})

vim.api.nvim_create_user_command("SearchAndReplaceByReferences", function()
    require("search-and-replace").replace_by_references()
end, {})

vim.api.nvim_create_user_command("SearchAndReplaceUndo", function()
    require("search-and-replace").undo()
end, {})
