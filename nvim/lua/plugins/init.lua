local fn = vim.fn
local install_path = fn.stdpath "data" .. "/site/pack/packer/start/packer.nvim"

if fn.empty(fn.glob(install_path)) > 0 then
	fn.system({'git', 'clone', '--depth=1', 'https://github.com/wbthomason/packer.nvim', install_path})
	vim.cmd "packadd packer.nvim"
	vim.cmd "PackerSync"
end

local nvimtree = require "plugins.confs.nvimtree"
local barbar = require "plugins.confs.barbar"
--local bufferline = require "plugins.confs.bufferline"
local gitsigns = require "plugins.confs.gitsigns"
local lualine = require "plugins.confs.lualine"
local lspc = require "plugins.confs.lspconfs"
local cmp = require "plugins.confs.cmp"
local telescope = require "plugins.confs.telescope"
local dashboard = require "plugins.confs.dashboard"

return require('packer').startup(function(use)
	use "wbthomason/packer.nvim"

	use(nvimtree)
	use(barbar)
	use(gitsigns)
	use(lualine)
	use(lspc)
	use(cmp)
	use(telescope)
	use(dashboard)

	use { 'lukas-reineke/indent-blankline.nvim',
		requires = 'nvim-treesitter/nvim-treesitter',
		config = function()
			require("indent_blankline").setup {
				space_char_blankline = " ",
				show_current_context = true,
			}
		end
	}

	--adding IDE capabilities
	use {
		'norcalli/nvim-colorizer.lua',
		config = function ()
			require 'colorizer'.setup({
				'*';
			},{
				mode = 'background'
			})
		end
	}

	use {
		'glepnir/lspsaga.nvim',
		branch = 'main',
		require = 'neovim/nvim-lspconfig',
		config = function ()
			--local colors = require "azul.core".get_colors()
			require('lspsaga').init_lsp_saga {
				diagnostic_header = { "✋", "👆", "👉", "🤏" },
				--symbol_in_winbar = { enable = true }
			}
		end
	}

	use { 'voldikss/vim-floaterm',
		--[[config = function()
			vim.cmd('FloatermNew')
			vim.cmd('FloatermHide')
			vim.cmd('stopinsert')
		end]]
		--somehow this doenst work
	}

	use {
		'nvim-treesitter/nvim-treesitter',
		requires = 'tree-sitter/tree-sitter',
		run = ':TSUpdate',
		--commit = '4cccb6f494eb255b32a290d37c35ca12584c74d0',
		config = function()
			require("nvim-treesitter.configs").setup {
				auto_install = true,
				sync_install = false,
				highlight = {
					enable = true,
					additional_vim_regex_highlighting = false,
				}
			}
		end
	}

	use {
		'folke/trouble.nvim',
		requires = 'folke/lsp-colors.nvim',
		config = function()
			local colors = require("azul.core").get_colors()
			require("lsp-colors").setup({
				Error = colors.color1,
				Warning = colors.color3,
				Information = colors.color4,
				Hint = colors.color6
			})
			require("trouble").setup{}
			vim.diagnostic.config({
				virtual_text = false
			})
		end
	}
end)
