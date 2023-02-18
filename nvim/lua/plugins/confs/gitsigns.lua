return {
	"lewis6991/gitsigns.nvim",
	name = "gitsigns",
    event = "BufEnter",
	config = function()
		local gs = require("gitsigns")
        gs.setup()
	end,
    keys = {
        { "<leader>gb", "<cmd>lua require('gitsigns').toggle_current_line_blame()<cr>" }
    }
}
