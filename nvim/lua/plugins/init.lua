local install_path = vim.fn.stdpath "data" .. "/site/pack/packer/start/packer.nvim"
local pack_bootstrap

if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
	vim.fn.system({'git', 'clone', '--depth=1', 'https://github.com/wbthomason/packer.nvim', install_path})
	vim.cmd [[packadd packer.nvim]]
	pack_bootstrap = true
end

local nvimtree = require "plugins.confs.nvimtree"
local barbar = require "plugins.confs.barbar"
local gitsigns = require "plugins.confs.gitsigns"
local lualine = require "plugins.confs.lualine"
local lspc = require "plugins.confs.lspconfs"
local cmp = require "plugins.confs.cmp"
local telescope = require "plugins.confs.telescope"
local dashboard = require "plugins.confs.dashboard"
local dap = require "plugins.confs.dap"

return require('packer').startup(function(use)
	use "wbthomason/packer.nvim"

	use {
		'windwp/nvim-autopairs',
		config = function() require("nvim-autopairs").setup {} end
	}

	use {
		'Shatur/neovim-session-manager',
		require = {
			'nvim-lua/plenary.nvim'
		},
		config = function ()
			local Path = require('plenary.path')
			require('session_manager').setup ({
				sessions_dir = Path:new(vim.fn.stdpath('data'), 'sessions'),
				path_replacer = '__',
				colon_replacer = '++',
				autoload_mode = require('session_manager.config').AutoloadMode.CurrentDir,
				autosave_last_session = true,
				autosave_ignore_not_normal = true,
				autosave_ignore_dirs = {},
				autosave_ignore_filetypes = {
					'gitcommit',
					'NvimTree',
					'toggleterm',
				},
				autosave_only_in_session = false,
				max_path_length = 80,
			})
			Map("n", "fs", "<cmd>SessionManager load_session<cr>", {})
			Map("n", "ds", "<cmd>SessionManager delete_session<cr>", {})
		end
	}

	use {
		'lukas-reineke/indent-blankline.nvim',
		requires = 'nvim-treesitter/nvim-treesitter',
		config = function()
			require("indent_blankline").setup {
				space_char_blankline = " ",
				show_current_context = true,
			}
		end
	}

	use {
		'NvChad/nvim-colorizer.lua',
		config = function ()
			require 'colorizer'.setup({})
        end
	}

	use {
		'glepnir/lspsaga.nvim',
		branch = 'main',
		require = 'neovim/nvim-lspconfig',
		config = function ()
			--local colors = require "azul.core".get_colors()
			require('lspsaga').setup{
				diagnostic_header = { "✋", "👆", "👉", "🤏" },
				symbol_in_winbar = {
					enable = false,
					separator = '  '
				},
				lightbulb = {
					enable = true,
					enable_in_insert = false,
					virtual_text = false
				},
			}
			Map("n", "ca", "<cmd>Lspsaga code_action <CR>", {})
			Map("n", "gr", "<cmd>Lspsaga rename <CR>", {})
			Map("i", "<C-R>", "<cmd>Lspsaga rename <CR>", {})
			Map("n", "gd", "<cmd>Lspsaga peek_definition <CR>", {})
			Map("n", "D", "<cmd>Lspsaga hover_doc <CR>", {})
			Map("i", "<C-D>", "<cmd>Lspsaga diagnostic_jump_next <CR>", {})
			Map("n", "<C-D>", "<cmd>Lspsaga diagnostic_jump_next <CR>", {})
		end
	}

	use {
		'akinsho/toggleterm.nvim',
		config = function ()
			local colors = require("azul.core").get_colors()
			require("toggleterm").setup {
				autochdir = true,
				direction = 'float',
				float_opts = {
					border = 'single'
				},
				highlights = {
					FloatBorder = {
						guifg=colors.contrast,
						guibg=colors.contrast
					}
				}
			}
			Map("n", "tt", "<cmd>ToggleTerm<CR>", {})
			Map("t", "<C-T>", "<cmd>ToggleTerm<CR>", {})
		end
	}

	use {
		'nvim-treesitter/nvim-treesitter',
		requires = {
			'tree-sitter/tree-sitter',
		},
		run = function()
			require("nvim-treesitter").install.update()
		end,
		config = function()
			require("nvim-treesitter.configs").setup {
				auto_install = true,
				sync_install = false,
                indent = {
                    enable = true
                },
				highlight = {
					enable = true,
					additional_vim_regex_highlighting = false,
				}
			}
		end
	}

	use {
		'j-hui/fidget.nvim',
		config = function ()
			require('fidget').setup{
                text = {
                    spinner = {"", "", "", "", "", ""}
                }
            }
		end
	}

	use {
		'stevearc/aerial.nvim',
		requires = {
			'nvim-treesitter/nvim-treesitter'
		},
		config = function ()
			require('aerial').setup{}
			Map("n", "<Space>a", "<cmd>AerialToggle<cr>", {})
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
			Map("n", "<Space>t", "<cmd>TroubleToggle<cr>", {})
		end
	}

	use(nvimtree)
	use(barbar)
	use(gitsigns)
	use(lualine)
	use(lspc)
	use(cmp)
	use(telescope)
	use(dashboard)
    use(dap)
	if pack_bootstrap then
		require("packer").sync()
	end
end)
