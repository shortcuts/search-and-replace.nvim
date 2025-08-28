local SearchAndReplace = {}

--- SearchAndReplace configuration with its default values.
---
---@type table
--- Default values:
---@eval return MiniDoc.afterlines_to_code(MiniDoc.current.eval_section)
SearchAndReplace.options = {
    -- Prints useful logs about what event are triggered, and reasons actions are executed.
    debug = false,
    -- Creates mappings for you to easily interact with the exposed commands.
    ---@type table
    mappings = {
        -- When `true`, creates all the mappings that are not set to `false`.
        ---@type boolean
        enabled = false,
        -- Sets a global mapping to Neovim, which will trigger the "in project" replace function.
        -- When `false`, the mapping is not created.
        ---@type string
        search_and_replace_in_project = "<Leader>srp",
        -- Sets a global mapping to Neovim, which will trigger the "by reference" replace function.
        -- When `false`, the mapping is not created.
        ---@type string
        search_and_replace_by_reference = "<Leader>srr",
        -- Sets a global mapping to Neovim, which will trigger the "undo" function.
        -- When `false`, the mapping is not created.
        ---@type string
        undo = "<Leader>sru",
    },
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

--- Registers the plugin mappings if the option is enabled.
---
---@param options table The mappins provided by the user.
---@param mappings table A key value map of the mapping name and its command.
---
---@private
local function register_mappings(options, mappings)
    -- all of the mappings are disabled
    if not options.enabled then
        return
    end

    for name, command in pairs(mappings) do
        -- this specific mapping is disabled
        if not options[name] then
            return
        end

        if (name == "widthUp" or name == "widthDown") and type(options[name]) ~= "string" then
            assert(
                type(options[name]) == "table"
                    and options[name]["mapping"] ~= nil
                    and options[name]["value"] ~= nil,
                string.format(
                    "`%s` must be a string or a table with the following properties {mapping: 'your_mapping', value: 5}",
                    name
                )
            )
            vim.api.nvim_set_keymap("n", options[name].mapping, command, { silent = true })
        else
            assert(type(options[name]) == "string", string.format("`%s` must be a string", name))
            vim.api.nvim_set_keymap("n", options[name], command, { silent = true })
        end
    end
end

--- Define your search-and-replace setup.
---
---@param options table Module config table. See |SearchAndReplace.options|.
---
---@usage `require("search-and-replace").setup()` (add `{}` with your |SearchAndReplace.options| table)
function SearchAndReplace.setup(options)
    SearchAndReplace.options = SearchAndReplace.defaults(options or {})

    register_mappings(SearchAndReplace.options.mappings, {
        search_and_replace_in_project = ":SearchAndReplaceInProject<CR>",
        search_and_replace_by_reference = ":SearchAndReplaceByReference<CR>",
        undo = ":SearchAndReplaceUndo<CR>",
    })

    return SearchAndReplace.options
end

return SearchAndReplace
