local cmp = require("cmp")
local luasnip = require("luasnip")
local lc = require("lspconfig")

local lspsaga = require 'lspsaga'
lspsaga.setup { -- defaults ...
	debug = false,
	use_saga_diagnostic_sign = true,
	-- diagnostic sign
	error_sign = "",
	warn_sign = "",
	hint_sign = "",
	infor_sign = "",
	diagnostic_header_icon = "  ",
	-- code action title icon
	code_action_icon = "",
	code_action_prompt = {
		enable = false,
		sign = true,
		sign_priority = 40,
		virtual_text = false,
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
	highlight_prefix = false,
}

cmp.setup({
	snippet = {
    	expand = function(args)
    		luasnip.lsp_expand(args.body)
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
		['<C-w>'] = cmp.mapping.scroll_docs(-4),
		['<C-s>'] = cmp.mapping.scroll_docs(4),
		['<C-e>'] = cmp.mapping.abort(),
		['<CR>'] = cmp.mapping.confirm({ select = false }),
	}),
    sources = cmp.config.sources({
		{ name = 'nvim_lsp' },
		{ name = 'luasnip' },
	})
})

require("lsp-colors").setup({
	Error = "#db4b4b",
	Warning = "#e0af68",
	Information = "#0db9d7",
	Hint = "#10B981"
})
require("trouble").setup{}

local cwd = vim.fn.substitute(vim.fn.getcwd(), '^.*/', '', '')

--print (pwd_name)

lc.sumneko_lua.setup{
	settings = {
		root_dir = "file://" .. vim.fn.getcwd(), --.git is default before cwd, so editing dots fucks with sumneko
		Lua = {
			runtime = {
				version = cwd == "awesome" and "5.2" or
					cwd == "nvim" and "LuaJIT" or nil,
			},
			diagnostics = {
            	-- Get the language server to recognize globals
				globals = cwd == "awesome" and {
                	"root", "awesome", "tag", "screen", "client",
					"modkey", "altkey", "mouse", "mousegrabber"
            	} or cwd == "nvim" and { "vim" } or { },
			},
			workspace = {
				checkThirdParty = false,
        		library = cwd == "awesome" and "/run/current-system/sw/share/awesome/lib" or cwd == "nvim" and vim.api.nvim_get_runtime_file("", true) or nil,
			},
			telemetry = { enable = false },
    	}
	}
}
lc.omnisharp.setup {
	cmd = { "omnisharp", "-lsp", "--hostPID", tostring(vim.fn.getpid()) }
}
lc.pylsp.setup{}
lc.hls.setup{}
