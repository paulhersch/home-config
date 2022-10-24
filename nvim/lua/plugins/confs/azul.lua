--return {
	--'Everblush/everblush.nvim',
	--'~/.config/nvim/lua/azul',
	--as = 'azul',
	--config = function()
		require("azul").setup({})
		--remove diagnostics at end of line
		vim.diagnostic.config({
			virtual_text = false
		})
		local colors = require("azul.core").get_colors()

		--[[local function hl(group, highlights)
			vim.api.nvim_set_hl(0, group, highlights)
		end

		--custom highlights for barbar.nvim
		hl('BufferCurrent', {fg = colors.foreground, bg = colors.contrast})
		hl('BufferCurrentIndex', {fg = colors.background, bg = colors.contrast})
		hl('BufferCurrentMod', {fg = colors.foreground, bg = colors.contrast, italic=true})
		hl('BufferCurrentSign', {fg = colors.color4, bg = colors.contrast})
		hl('BufferCurrentTarget', {fg = colors.color4, bg = colors.contrast})

		hl('BufferVisible', {fg = colors.comment, bg = colors.background})
		hl('BufferVisibleIndex', {fg = colors.comment, bg = colors.background})
		hl('BufferVisibleMod', {fg = colors.color0, bg = colors.background, italic=true})
		hl('BufferVisibleSign', {fg = colors.color0, bg = colors.background})
		hl('BufferVisibleTarget', {fg = colors.color0, bg = colors.background})

		hl('BufferInactive', {fg = colors.comment, bg = colors.background})
		hl('BufferInactiveIndex', {fg = colors.comment, bg = colors.background})
		hl('BufferInactiveMod', {fg = colors.color0, bg = colors.background, italic=true})
		hl('BufferInactiveSign', {fg = colors.color0, bg = colors.background})
		hl('BufferInactiveTarget', {fg = colors.color0, bg = colors.background})

		hl('BufferTabpages', {fg=colors.color4, bg=colors.background})]]
	--end
--}
