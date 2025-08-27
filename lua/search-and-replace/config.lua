local SearchAndReplace = {}

--- SearchAndReplace configuration with its default values.
---
---@type table
--- Default values:
---@eval return MiniDoc.afterlines_to_code(MiniDoc.current.eval_section)
SearchAndReplace.options = {
    -- Prints useful logs about what event are triggered, and reasons actions are executed.
    debug = false,
}

---@private
local defaults = vim.deepcopy(SearchAndReplace.options)

--- Defaults SearchAndReplace options by merging user provided options with the default plugin values.
---
---@param options table Module config table. See |SearchAndReplace.options|.
---
---@private
function SearchAndReplace.defaults(options)
    SearchAndReplace.options =
        vim.deepcopy(vim.tbl_deep_extend("keep", options or {}, defaults or {}))

    -- let your user know that they provided a wrong value, this is reported when your plugin is executed.
    assert(
        type(SearchAndReplace.options.debug) == "boolean",
        "`debug` must be a boolean (`true` or `false`)."
    )

    return SearchAndReplace.options
end

--- Define your search-and-replace setup.
---
---@param options table Module config table. See |SearchAndReplace.options|.
---
---@usage `require("search-and-replace").setup()` (add `{}` with your |SearchAndReplace.options| table)
function SearchAndReplace.setup(options)
    SearchAndReplace.options = SearchAndReplace.defaults(options or {})

    return SearchAndReplace.options
end

return SearchAndReplace
