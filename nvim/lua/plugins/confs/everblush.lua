
return {
    'Everblush/everblush.nvim',
    as = 'everblush',
    config = function()
        require("everblush").setup({
            nvim_tree = { contrast = false }
        })
        --remove diagnostics at end of line
        vim.diagnostic.config({
            virtual_text = false
        })
        local evblushcols = require("everblush.core").get_colors()

        local function hl(group, highlights)
            vim.api.nvim_set_hl(0, group, highlights)
        end

        hl('NvimTreeOpenedFolderName', { fg = evblushcols.color4 })
        hl('NvimTreeEmptyFolderName', { fg = evblushcols.comment })
        hl('NvimTreeNormal', { fg = evblushcols.color7 })

        hl('NvimTreeOpenedFile', { fg = evblushcols.foreground, italic=true })

        hl('VertSplit', {bg=evblushcols.background, fg=evblushcols.color0}) --visually remove splits
        hl('CursorLine', {bg=evblushcols.background})
        hl('CursorLineNr', {fg=evblushcols.foreground})
        hl('Comment', {italic=true, fg = evblushcols.comment})
        hl('TSComment', {italic=true, fg = evblushcols.comment})
        hl('TSKeyword', {fg = evblushcols.color5 , italic=true}) --manual override

        --simple highlights for Telescope
        hl('TelescopeNormal', {bg = evblushcols.color0})
        hl('TelescopeBorder', {bg = evblushcols.color0, fg = evblushcols.color0})
        hl('TelescopePromptBorder', {bg = evblushcols.color0, fg = evblushcols.color0})
        --hl('TelescopePromptNormal', {bg = evblushcols.color0, fg = evblushcols.foreground})
        hl('TelescopePromptTitle', {bg = evblushcols.comment, fg = evblushcols.color4})

        hl('TelescopePreviewNormal', {bg = evblushcols.contrast, fg = evblushcols.foreground})
        hl('TelescopePreviewBorder', {bg = evblushcols.contrast, fg = evblushcols.contrast})
        hl('TelescopePreviewTitle', {bg = evblushcols.comment, fg = evblushcols.color4})

        --custom highlights for barbar.nvim
        hl('BufferCurrent', {fg = evblushcols.foreground, bg = evblushcols.contrast})
        hl('BufferCurrentIndex', {fg = evblushcols.background, bg = evblushcols.contrast})
        hl('BufferCurrentMod', {fg = evblushcols.foreground, bg = evblushcols.contrast, italic=true})
        hl('BufferCurrentSign', {fg = evblushcols.color4, bg = evblushcols.contrast})
        hl('BufferCurrentTarget', {fg = evblushcols.color4, bg = evblushcols.contrast})

        hl('BufferVisible', {fg = evblushcols.comment, bg = evblushcols.background})
        hl('BufferVisibleIndex', {fg = evblushcols.comment, bg = evblushcols.background})
        hl('BufferVisibleMod', {fg = evblushcols.color0, bg = evblushcols.background, italic=true})
        hl('BufferVisibleSign', {fg = evblushcols.color0, bg = evblushcols.background})
        hl('BufferVisibleTarget', {fg = evblushcols.color0, bg = evblushcols.background})

        hl('BufferInactive', {fg = evblushcols.comment, bg = evblushcols.background})
        hl('BufferInactiveIndex', {fg = evblushcols.comment, bg = evblushcols.background})
        hl('BufferInactiveMod', {fg = evblushcols.color0, bg = evblushcols.background, italic=true})
        hl('BufferInactiveSign', {fg = evblushcols.color0, bg = evblushcols.background})
        hl('BufferInactiveTarget', {fg = evblushcols.color0, bg = evblushcols.background})

        hl('BufferTabpages', {fg=evblushcols.color4, bg=evblushcols.background})
    end
}
