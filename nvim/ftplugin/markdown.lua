local success, cmp = pcall(require, "cmp")

local function add_emoji_source(cmp)
    local sources_prev = cmp.get_config().sources
    table.insert(sources_prev, { name = 'emoji', insert = true })

    cmp.setup.buffer({
        sources = sources_prev
    })
end

if success then
    add_emoji_source(cmp)
else
    vim.notify(
        "Couldnt add emoji Source to cmp, use :LoadMDSources to load manually",
        vim.log.levels.WARN
    )

    vim.api.nvim_create_user_command("LoadMDSources", function()
        local success, cmp = pcall(require, "cmp")

        if success then
            add_emoji_source(cmp)
            vim.api.nvim_del_user_command("LoadMDSources")
        else
            vim.notify(
                "Couldnt add emoji Source to cmp, use :LoadMDSources to load manually, but make sure cmp is loaded first",
                vim.log.levels.WARN
            )
        end
    end, { desc = "Reload cmp.nvim ftplugin setup for markdown" })
end
