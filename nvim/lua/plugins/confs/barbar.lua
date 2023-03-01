return {
	'romgrk/barbar.nvim',
	dependencies = {
		'nvim-tree/nvim-web-devicons',
		'nvim-tree/nvim-tree.lua'
	},
    lazy = true,
    -- check if barbar needs to be loaded
    init = function ()
        local ls_buf = vim.api.nvim_list_bufs
        local buf_opt = vim.api.nvim_buf_get_option
        local function check_load()
            local len = 0
            local buffers = ls_buf()
            for _, buffer in ipairs(buffers) do
                if buf_opt(buffer, 'buflisted') then
                    len = len + 1
                end
            end
            return len > 1
        end
        local self
        self = vim.api.nvim_create_autocmd("BufEnter",{
            callback = function ()
                if check_load() then
                    require"bufferline"
                    vim.api.nvim_del_autocmd(self)
                end
            end
        })
    end,
    config = function()
        require('bufferline').setup {
            animation = false,
            auto_hide = true,
            icon_separator_active = '',-- vim.opt.fillchars.vert,
			icon_separator_inactive ='',-- vim.opt.fillchars.vert
		}

		local nvim_tree_events = require('nvim-tree.events')
		local bufferline_api = require('bufferline.api')

		local function get_tree_size()
			return require('nvim-tree.view').View.width
		end

		nvim_tree_events.subscribe("TreeOpen", function()
			bufferline_api.set_offset(get_tree_size())
		end)

		nvim_tree_events.subscribe("Resize", function()
			bufferline_api.set_offset(get_tree_size())
		end)

		nvim_tree_events.subscribe("TreeClose", function()
			bufferline_api.set_offset(0)
		end)
	end
}
