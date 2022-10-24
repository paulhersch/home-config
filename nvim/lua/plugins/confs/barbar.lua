return {
	'romgrk/barbar.nvim',
	requires = {
		'kyazdani42/nvim-web-devicons',
		'kyazdani42/nvim-tree.lua'
	},
	as = 'bufferline',
	config = function()
		require('bufferline').setup{
			animation = false,
			auto_hide = true,
			icon_separator_active = '┃',-- vim.opt.fillchars.vert,
			icon_separator_inactive ='┃',-- vim.opt.fillchars.vert
		}

		local nvim_tree_events = require('nvim-tree.events')
		local bufferline_state = require('bufferline.state')

		local function get_tree_size()
			return require('nvim-tree.view').View.width
		end

		nvim_tree_events.subscribe("TreeOpen", function()
			bufferline_state.set_offset(get_tree_size())
		end)

		nvim_tree_events.subscribe("Resize", function()
			bufferline_state.set_offset(get_tree_size())
		end)

		nvim_tree_events.subscribe("TreeClose", function()
			bufferline_state.set_offset(0)
		end)
	end
}
