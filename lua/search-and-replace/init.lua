local main = require("search-and-replace.main")
local config = require("search-and-replace.config")

local SearchAndReplace = {}

--- Toggle the plugin by calling the `enable`/`disable` methods respectively.
function SearchAndReplace.toggle()
    if _G.SearchAndReplace.config == nil then
        _G.SearchAndReplace.config = config.options
    end

    main.toggle("public_api_toggle")
end

--- Initializes the plugin, sets event listeners and internal state.
function SearchAndReplace.enable(scope)
    if _G.SearchAndReplace.config == nil then
        _G.SearchAndReplace.config = config.options
    end

    main.toggle(scope or "public_api_enable")
end

--- Disables the plugin, clear highlight groups and autocmds, closes side buffers and resets the internal state.
function SearchAndReplace.disable()
    main.toggle("public_api_disable")
end

-- setup SearchAndReplace options and merge them with user provided ones.
function SearchAndReplace.setup(opts)
    _G.SearchAndReplace.config = config.setup(opts)
end

_G.SearchAndReplace = SearchAndReplace

return _G.SearchAndReplace
