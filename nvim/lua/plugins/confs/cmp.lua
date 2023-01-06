return {
	'hrsh7th/nvim-cmp',
	requires = {
		'hrsh7th/cmp-nvim-lsp',
		'hrsh7th/cmp-path',
		'hrsh7th/cmp-buffer',
		'saadparwaiz1/cmp_luasnip',
		'L3MON4D3/LuaSnip',
		'ray-x/cmp-treesitter',
		'hrsh7th/cmp-nvim-lsp-signature-help',
		'hrsh7th/cmp-cmdline'
	},
	config = function()
		local luasnip = require("luasnip")
		local cmp = require("cmp")

		local cmp_kinds = {
			Text = "",
			Method = "",
			Function = "",
			Constructor = "",
			Field = "ﰠ",
			Variable = "",
			Class = "ﴯ",
			Interface = "",
			Module = "",
			Property = "ﰠ",
			Unit = "塞",
			Value = "",
			Enum = "",
			Keyword = "",
			Snippet = "",
			Color = "",
			File = "",
			Reference = "",
			Folder = "",
			EnumMember = "",
			Constant = "",
			Struct = "פּ",
			Event = "",
			Operator = "",
			TypeParameter = ""
		}
		cmp.setup.cmdline("/", {
			mapping = cmp.mapping.preset.cmdline(),
			sources = {
				{ name = 'buffer' }
			}
		})
		cmp.setup.cmdline(':', {
			mapping = cmp.mapping.preset.cmdline(),
			sources = cmp.config.sources({
				{ name = 'path' }
			}, {
				{
					name = 'cmdline',
					option = {
						ignore_cmds = { 'Man', '!' }
					}
				}
			})
		})
		cmp.setup({
			snippet = {
				expand = function(args)
					luasnip.lsp_expand(args.body)
				end,
			},
			window = {
				completion = {
					col_offset = -3,
					side_padding = 0,
				},
			},
			formatting = {
				fields = { "kind", "abbr", "menu" },
				format = function(_, vim_item)
					if vim_item.kind ~= nil then
						vim_item.menu = "    (" .. vim_item.kind .. ")"
						vim_item.kind = " " .. (cmp_kinds[vim_item.kind] or "_") .. " "
					else
						-- backup in case kind just doesnt exist
						vim_item.kind = " _ "
					end
					return vim_item
				end,
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
				['<CR>'] = cmp.mapping.confirm({ select = false }),
			}),
			sources = {
				{ name = 'nvim_lsp' },
				{ name = 'luasnip' },
				{ name = 'treesitter' },
				{ name = 'path' },
				{ name = 'nvim_lsp_signature_help' }
			}
		})
	end
}
