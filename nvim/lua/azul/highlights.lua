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
		hl(0, 'NvimTreeNormal', { bg = colors.background_dark })
		hl(0, 'NvimTreeNormalNC', { bg = colors.background_dark })
		hl(0, 'NvimTreeEndOfBuffer', { bg = colors.background_dark, fg = colors.background_dark })
		hl(0, 'NvimTreeEndOfBufferNC', { bg = colors.background_dark, fg = colors.background_dark })
		hl(0, 'NvimTreeWinSeparator', { fg = colors.background_dark, bg = colors.background_dark })
		hl(0, 'NvimTreeVertSplit', { fg = colors.background_dark, bg = colors.background_dark })
		hl(0, 'NvimTreeCursorLine', { bg = colors.background_dark, fg = colors.foreground })
		hl(0, 'NvimTreeFolderIcon', { bg = colors.background_dark, fg = colors.color4 })
        hl(0, 'NvimTreeIndentMarker', { bg = colors.background_dark, fg = colors.color0 })
	end
	local override = opts.override or {}
	for group, properties in pairs(override) do
		hl(0, group, properties)
	end
end

return M
