-- You can use this loaded variable to enable conditional parts of your plugin.
if _G.SearchAndReplaceLoaded then
    return
end

_G.SearchAndReplaceLoaded = true

-- Useful if you want your plugin to be compatible with older (<0.7) neovim versions
if vim.fn.has("nvim-0.7") == 0 then
    vim.cmd("command! SearchAndReplace lua require('search-and-replace').toggle()")
else
    vim.api.nvim_create_user_command("SearchAndReplace", function()
        require("search-and-replace").toggle()
    end, {})
end
