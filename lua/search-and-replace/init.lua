local main = require("search-and-replace.main")
local config = require("search-and-replace.config")

local SearchAndReplace = {}

function SearchAndReplace.replace_in_project()
    main.replace_in_project("replace_in_project")
end

function SearchAndReplace.replace_by_references()
    main.replace_by_references("replace_by_references")
end

function SearchAndReplace.setup(opts)
    _G.SearchAndReplace.config = config.setup(opts)
end

_G.SearchAndReplace = SearchAndReplace

return _G.SearchAndReplace
