return {
	'hrsh7th/nvim-cmp',
	dependencies = {
		'hrsh7th/cmp-nvim-lsp',
		'hrsh7th/cmp-path',
		'hrsh7th/cmp-buffer',
		'hrsh7th/vim-vsnip',
		'hrsh7th/cmp-vsnip',
		'rafamadriz/friendly-snippets',
		'ray-x/cmp-treesitter',
		'hrsh7th/cmp-nvim-lsp-signature-help',
		'hrsh7th/cmp-cmdline',
		'windwp/nvim-autopairs'
	},
    event = "LspAttach",
	config = function()
		local cmp = require("cmp")
		local cmp_autopair = require ("nvim-autopairs.completion.cmp")

		local cmp_kinds = {
			Text = " ",
			Method = " ",
			Function = " ",
			Constructor = " ",
			Field = " ",
			Variable = " ",
			Class = " ",
			Interface = " ",
			Module = " ",
			Property = " ",
			Unit = " ",
			Value = " ",
			Enum = " ",
			Keyword = " ",
			Snippet = " ",
			Color = " ",
			File = " ",
			Reference = " ",
			Folder = " ",
			EnumMember = " ",
			Constant = " ",
			Struct = " ",
			Event = " ",
			Operator = " ",
			TypeParameter = " "
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
						ignore_cmds = { 'Man' }
					}
				}
			})
		})

		local feedkey = function(key, mode)
  			vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), mode, true)
		end

		cmp.setup({
			snippet = {
				expand = function(args)
					vim.fn["vsnip#anonymous"](args.body)
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
						vim_item.kind = " " .. (cmp_kinds[vim_item.kind] or " ") .. " "
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
					elseif vim.fn["vsnip#available"](1) == 1 then
				        feedkey("<Plug>(vsnip-expand-or-jump)", "")
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
				{ name = 'vsnip' },
				{ name = 'treesitter' },
				{ name = 'path' },
				{ name = 'nvim_lsp_signature_help' }
			}
		})
		cmp.event:on (
			'confirm_done',
			cmp_autopair.on_confirm_done()
		)
	end
}
