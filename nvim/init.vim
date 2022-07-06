set encoding=utf-8

" vim Plug + Installed Plugins {{{
let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')

Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'tree-sitter/tree-sitter'
Plug 'andweeb/presence.nvim'
Plug 'nvim-lualine/lualine.nvim'
Plug 'luochen1990/rainbow'
Plug 'lukas-reineke/indent-blankline.nvim'
"Plug 'glepnir/dashboard-nvim'

"colorschemes
Plug 'sonph/onehalf', { 'rtp': 'vim' }
Plug 'sainnhe/everforest'
Plug 'decaycs/decay.nvim'
Plug 'cocopon/iceberg.vim'
Plug 'ozkanonur/nimda.vim'
Plug 'Everblush/everblush.nvim', { 'as': 'everblush' }
Plug 'folke/tokyonight.nvim', { 'branch': 'main' }

"adding IDE capabilities
Plug 'neovim/nvim-lspconfig'
Plug 'lewis6991/gitsigns.nvim'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/nvim-cmp'
Plug 'saadparwaiz1/cmp_luasnip'
Plug 'tami5/lspsaga.nvim'

Plug 'L3MON4D3/LuaSnip'
Plug 'kyazdani42/nvim-web-devicons'
Plug 'folke/trouble.nvim'
Plug 'folke/lsp-colors.nvim'
Plug 'kyazdani42/nvim-tree.lua'

call plug#end()

"autoupdate for Plugins
"PlugUpdate
"quit

"}}}

" "pure" settings {{{
set tabstop=4
set shiftwidth=4
let g:rainbow_active = 0
:nnoremap h :vertical resize +5 <CR>
:nnoremap l :vertical resize -5 <CR>
:nnoremap j :resize -5 <CR>
:nnoremap k :resize +5 <CR>
:tnoremap <Esc> <C-\><C-n>
:nnoremap <C-r> :RainbowToggle <CR>
:nnoremap <C-t> :tabnew <CR>

set number relativenumber

set clipboard+=unnamedplus
set hidden
set nobackup
set nowritebackup
set updatetime=300

set fdm=marker
set completeopt=menu,menuone,noselect

if exists('+termguicolors')
  let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
  let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
  set termguicolors
endif
"}}}

set noshowmode
" }}}

" neovide settings {{{
let g:neovide_cursor_animation_length=0.05
let g:neovide_cursor_tail_length=0.1
set guifont=CaskaydiaCove\ Nerd\ Font:h11
" }}}

" rich presence settings {{{
" General options
let g:presence_auto_update         = 1
let g:presence_neovim_image_text   = "You never seen Nvim?"
let g:presence_main_image          = "neovim"
let g:presence_client_id           = "793271441293967371"
"let g:presence_log_level	   = "debug"
let g:presence_debounce_timeout    = 10
let g:presence_enable_line_number  = 0
let g:presence_blacklist           = []
let g:presence_buttons             = 1
let g:presence_file_assets         = {}

" Rich Presence text options
let g:presence_editing_text        = "Editing %s"
let g:presence_file_explorer_text  = "Browsing %s"
let g:presence_git_commit_text     = "Committing changes"
let g:presence_plugin_manager_text = "Managing plugins"
let g:presence_reading_text        = "Reading %s"
let g:presence_workspace_text      = "Working on %s"
" }}}

" lspsaga binds {{{
nnoremap <silent><leader>ca <cmd>lua require('lspsaga.codeaction').code_action()<CR>
vnoremap <silent><leader>ca :<C-U>lua require('lspsaga.codeaction').range_code_action()<CR>
nnoremap <silent>K :Lspsaga hover_doc<CR>
nnoremap <silent>gs :Lspsaga signature_help<CR>
nnoremap <silent>gr :Lspsaga rename<CR>
nnoremap <silent>gd :Lspsaga preview_definition<CR>
nnoremap <silent><leader><Enter> :Lspsaga open_floaterm<CR>
nnoremap <silent><leader><Esc> :Lspsaga close_floaterm<CR>
" }}}

set background=dark
colorscheme everblush

" Lua plugins setup {{{
lua <<EOF
table.unpack = table.unpack or unpack

require("nvim-tree").setup()
require("gitsigns").setup()
require("trouble").setup{}
--require("bufferline").setup{}
local lualine = require("lualine")
local lspsaga = require("lspsaga")
local lc = require("lspconfig")
local luasnip = require("luasnip")
local cmp = require("cmp")
local tsconf = require("nvim-treesitter.configs")
local blankline = require("indent_blankline")
--[[local db = require("dashboard")

db.custom_header = {
		"⣞⢽⢪⢣⢣⢣⢫⡺⡵⣝⡮⣗⢷⢽⢽⢽⣮⡷⡽⣜⣜⢮⢺⣜⢷⢽⢝⡽⣝ ",
		"⠸⡸⠜⠕⠕⠁⢁⢇⢏⢽⢺⣪⡳⡝⣎⣏⢯⢞⡿⣟⣷⣳⢯⡷⣽⢽⢯⣳⣫⠇",
		"⠀⠀⢀⢀⢄⢬⢪⡪⡎⣆⡈⠚⠜⠕⠇⠗⠝⢕⢯⢫⣞⣯⣿⣻⡽⣏⢗⣗⠏⠀",
		"⠀⠪⡪⡪⣪⢪⢺⢸⢢⢓⢆⢤⢀⠀⠀⠀⠀⠈⢊⢞⡾⣿⡯⣏⢮⠷⠁⠀⠀ ",
		"⠀⠀⠀⠈⠊⠆⡃⠕⢕⢇⢇⢇⢇⢇⢏⢎⢎⢆⢄⠀⢑⣽⣿⢝⠲⠉⠀⠀⠀⠀",
		"⠀⠀⠀⠀⠀⡿⠂⠠⠀⡇⢇⠕⢈⣀⠀⠁⠡⠣⡣⡫⣂⣿⠯⢪⠰⠂⠀⠀⠀⠀",
		"⠀⠀⠀⠀⡦⡙⡂⢀⢤⢣⠣⡈⣾⡃⠠⠄⠀⡄⢱⣌⣶⢏⢊⠂⠀⠀⠀⠀⠀⠀",
		"⠀⠀⠀⠀⢝⡲⣜⡮⡏⢎⢌⢂⠙⠢⠐⢀⢘⢵⣽⣿⡿⠁⠁⠀⠀⠀⠀⠀⠀⠀",
		"⠀⠀⠀⠀⠨⣺⡺⡕⡕⡱⡑⡆⡕⡅⡕⡜⡼⢽⡻⠏⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
		"⠀⠀⠀⠀⣼⣳⣫⣾⣵⣗⡵⡱⡡⢣⢑⢕⢜⢕⡝⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
		"⠀⠀⠀⣴⣿⣾⣿⣿⣿⡿⡽⡑⢌⠪⡢⡣⣣⡟⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
		"⠀⠀⠀⡟⡾⣿⢿⢿⢵⣽⣾⣼⣘⢸⢸⣞⡟⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
		"⠀⠀⠀⠀⠁⠇⠡⠩⡫⢿⣝⡻⡮⣒⢽⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
}
db.custom_center = {
	{ icon = "", desc = " Open Nvimtree			", action = "NvimTreeOpen" }
}]]

lualine.setup {
	options = {
		icons_enabled = true,
		theme = 'auto',
		component_separators = { left = '', right = ''},
		section_separators = { left = '', right = ''},
		disabled_filetypes = {},
		always_divide_middle = true,
		globalstatus = false,
	},
	sections = {
		lualine_a = { 'mode' },
		lualine_b = { 'filename' },
		lualine_c = { 'branch' },
		lualine_x = { },
		lualine_y = { 'encoding', 'filetype' },
		lualine_z = { 'location' }
  	},
	inactive_sections = {
		lualine_a = { },
		lualine_b = { },
		lualine_c = { 'filename' },
		lualine_x = { 'location' },
		lualine_y = {},
		lualine_z = {}
	},
	tabline = { },
	extensions = {}
}

blankline.setup {
    space_char_blankline = "",
    show_current_context = true,
    show_current_context_start = true,
}

tsconf.setup {
  -- A list of parser names, or "all"
	ensure_installed = "all",
	sync_install = false,
	highlight = {
    -- `false` will disable the whole extension
		enable = true,
		additional_vim_regex_highlighting = false,
	},
}

lc.sumneko_lua.setup{
	settings = {
		Lua = {
			diagnostics = {
            	-- Get the language server to recognize globals
				globals = {
                	"root", "awesome", "tag", "screen", "client",
					"modkey", "altkey", "mouse", "mousegrabber"
            	},
			},
			workspace = {
        		library = "/run/current-system/sw/share/awesome/lib"
			},
			telemetry = { enable = false },
    	}
	}
}
lc.omnisharp.setup{
	cmd = { "omnisharp", "-lsp", "--hostPID", tostring(vim.fn.getpid()) }
}
lc.pylsp.setup{}
lc.hls.setup{}

lspsaga.setup { -- defaults ...
	debug = true,
	use_saga_diagnostic_sign = true,
	-- diagnostic sign
	error_sign = "",
	warn_sign = "",
	hint_sign = "",
	infor_sign = "",
	diagnostic_header_icon = "   ",
	-- code action title icon
	code_action_icon = " ",
	code_action_prompt = {
		enable = true,
		sign = true,
		sign_priority = 40,
		virtual_text = true,
	},
	finder_definition_icon = "  ",
	finder_reference_icon = "  ",
	max_preview_lines = 10,
	finder_action_keys = {
		open = "o",
		vsplit = "s",
		split = "i",
		quit = "q",
		scroll_down = "<C-f>",
		scroll_up = "<C-b>",
	},
	code_action_keys = {
		quit = "q",
		exec = "<CR>",
	},
	rename_action_keys = {
		quit = "<C-c>",
		exec = "<CR>",
	},
	definition_preview_icon = "  ",
	border_style = "single",
	rename_prompt_prefix = "➤",
	rename_output_qflist = {
		enable = false,
		auto_open_qflist = false,
	},
	server_filetype_map = {},
	diagnostic_prefix_format = "%d. ",
	diagnostic_message_format = "%m %c",
	highlight_prefix = true,
}


local has_words_before = function()
     local line, col = table.unpack(vim.api.nvim_win_get_cursor(0))
     return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

cmp.setup({
	snippet = {
    	expand = function(args)
    		require('luasnip').lsp_expand(args.body)
		end,
    },
    window = {
    	completion = cmp.config.window.bordered(),
    	documentation = cmp.config.window.bordered(),
    },
    mapping = cmp.mapping.preset.insert({
		["<Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_next_item()
			elseif luasnip.expand_or_jumpable() then
				luasnip.expand_or_jump()
			else
				fallback()
			end
		end, { "i", "s" }),
		['<C-b>'] = cmp.mapping.scroll_docs(-4),
		['<C-f>'] = cmp.mapping.scroll_docs(4),
		['<C-Space>'] = cmp.mapping.complete(),
		['<C-e>'] = cmp.mapping.abort(),
		['<CR>'] = cmp.mapping.confirm({ select = false }),
	}),
    sources = cmp.config.sources({
		{ name = 'nvim_lsp' },
		{ name = 'luasnip' },
	},
	{
		{ --[[name = 'buffer']] },
    })
})

require("lsp-colors").setup({
	Error = "#db4b4b",
	Warning = "#e0af68",
	Information = "#0db9d7",
	Hint = "#10B981"
})

EOF
"}}}
