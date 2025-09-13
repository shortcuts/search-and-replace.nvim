local main = require("search-and-replace.main")
local config = require("search-and-replace.config")

local SearchAndReplace = {}

function SearchAndReplace.search_and_replace_by_pattern()
    main.search_and_replace_by_pattern("search and replace by pattern")
end

function SearchAndReplace.replace_by_pattern()
    main.replace_by_pattern("by pattern")
end

function SearchAndReplace.replace_by_references()
    main.replace_by_references("by reference")
end

function SearchAndReplace.replace_undo()
    main.replace_undo("replace undo")
end

function SearchAndReplace.setup(opts)
    _G.SearchAndReplace.config = config.setup(opts)
end

_G.SearchAndReplace = SearchAndReplace

return _G.SearchAndReplace
