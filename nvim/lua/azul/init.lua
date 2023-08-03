local M = {}
local highlights = require('azul.highlights')

function M.setup (opts)
	if opts == nil then
		opts = {
            dark = false
        }
	end

    local colors
    if opts.dark then
     	colors = require('azul.core').get_colors()
    else
        colors = require('azul.core_light').get_colors()
    end

	vim.opt.termguicolors = true
	highlights.highlight_all(colors, opts)
end

return M
