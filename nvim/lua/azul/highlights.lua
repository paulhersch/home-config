local M = {}
local hl = vim.api.nvim_set_hl
local config = require('azul.config')

function M.highlight_all(colors, opts)
    if opts.transparent_background == true then
        colors.background = "none"
    end
    local base_highlights = config.highlights_base(colors)
    for group, properties in pairs(base_highlights) do
        hl(0, group, properties)
    end
    local ntree = opts.nvim_tree or { contrast = false }
    if ntree.contrast == true then
        hl(0, 'NvimTreeNormal', { bg = colors.contrast })
        hl(0, 'NvimTreeNormalNC', { bg = colors.contrast })
        hl(0, 'NvimTreeEndOfBuffer', { bg = colors.contrast, fg = colors.contrast })
        hl(0, 'NvimTreeEndOfBufferNC', { bg = colors.contrast, fg = colors.contrast })
        hl(0, 'NvimTreeVertSplit', { fg = colors.background, bg = colors.background })
        hl(0, 'NvimTreeCursorLine', { bg = colors.contrast, fg = colors.foreground })
    end
    local override = opts.override or {}
    for group, properties in pairs(override) do
        hl(0, group, properties)
    end
end

return M
