return {
	'lewis6991/gitsigns.nvim',
	as = 'gitsigns',
	config = function()
		local gs = require("gitsigns")
        gs.setup()
        Map('n', '<leader>gb', "<cmd>lua require('gitsigns').toggle_current_line_blame()<cr>", {})
	end
}
