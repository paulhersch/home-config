local a = vim.api
local M = {}

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

    vim.api.nvim_buf_create_user_command(0, "LoadMDSources", function()
        local success, cmp = pcall(require, "cmp")

        if success then
            add_emoji_source(cmp)
            vim.api.nvim_buf_del_user_command(0, "LoadMDSources")
        else
            vim.notify(
                "Couldnt add emoji Source to cmp, use :LoadMDSources to load manually, but make sure cmp is loaded first",
                vim.log.levels.WARN
            )
        end
    end, { desc = "Reload cmp.nvim ftplugin setup for markdown" })
end

-- this variable will be used to fill out the input field in case someone runs the export
-- command twice. I usually want to export to the same file again, if something went wrong,
-- so this will be filled out automatically
local previous_filename = ""

vim.api.nvim_buf_create_user_command(0, "PandocExport", function(opts)
    local content_to_export = {}
    -- range == 2 -> we have a first and last line supplied to this cmd
    if opts.range and opts.range == 2 then
        content_to_export = vim.api.nvim_buf_get_lines(0, opts.line1 - 1, opts.line2, false)
    else
        -- if no range supplied export whole file
        content_to_export = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    end

    vim.ui.input({ prompt = "Filename to export to:", default = previous_filename }, function(input)
        if not input or input == "" then
            return
        end
        previous_filename = input
        -- pipe file contents into pandoc
        vim.system({ "pandoc", "-o", input }, {
            stdin = table.concat(content_to_export, "\n"),
            text = true,
            cwd = vim.fn.getcwd(),
        }, function(obj)
            if obj.code == 0 then
                return
            else
                -- error happened, so we are going to show it to the user
                vim.notify("Error during pandoc export!\n" .. (obj.stderr or ""), vim.log.levels.ERROR, {})
            end
        end)
    end)
end, {
    desc = "Export either selected range via pandoc or the whole file if called without a range",
    range = true
})

a.nvim_create_augroup("PandocAutoExport", { clear = false })

local function render_pandoc(fname)
    local new_fname = string.gsub(fname, ".md", ".pdf")
    return vim.system({ "pandoc", "-o", new_fname, fname }, {
        text = true,
        cwd = vim.fn.getcwd(),
    }, function(obj)
        if obj.code == 0 then
            return
        else
            -- error happened, so we are going to show it to the user
            vim.notify("Error during pandoc export!\n" .. (obj.stderr or ""), vim.log.levels.ERROR, {})
        end
    end), new_fname
end

a.nvim_buf_create_user_command(0, "PandocPreviewToggle", function(opts)
    local buf = a.nvim_get_current_buf()
    local succ, res = pcall(a.nvim_buf_get_var, buf, "pandoc_preview_enabled")
    if succ and res then
        local au_cmd = a.nvim_get_autocmds({ group = a.nvim_create_augroup("PandocAutoExport", { clear = false }), buffer =
        buf })[1]
        a.nvim_del_autocmd(au_cmd)
        a.nvim_buf_set_var(buf, "pandoc_preview_enabled", false)
    else
        local fname = a.nvim_buf_get_name(buf)
        a.nvim_create_autocmd("BufWritePost", {
            group = a.nvim_create_augroup("PandocAutoExport", { clear = false }),
            buffer = buf,
            callback = function()
                render_pandoc(fname)
            end
        })
        a.nvim_buf_set_var(buf, "pandoc_preview_enabled", true)

        local sys_obj, exported_fname = render_pandoc(fname)
        sys_obj:wait()
        vim.ui.open(exported_fname)
    end
end, {
    desc = "Start compiling on write for md files via pandoc to pdf conversion"
})
