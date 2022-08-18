local cmp = require("cmp")
local luasnip = require("luasnip")
local lc = require("lspconfig")

require('renamer').setup {
    title = 'Rename',
    padding = {
        top = 0,
        left = 0,
        right = 0,
        bottom = 0
    },
    border = true,
    -- Whether or not to highlight the current word references through LSP
    show_refs = true,
    -- Whether or not to enter the new name through the UI or Neovim's `input` prompt
    with_popup = true,
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
  --      { name = 'spell' }
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
                library = cwd == "awesome" and "/run/current-system/sw/share/awesome/lib" or (cwd == "nvim" and vim.api.nvim_get_runtime_file("", true) or nil),
            },
            telemetry = { enable = false },
        }
    }
}
lc.omnisharp.setup {
    cmd = { "omnisharp", "-lsp", "--hostPID", tostring(vim.fn.getpid()) }
}
lc.pylsp.setup{
    settings = {
        pylsp = {
            plugins = {
                pycodestyle = {
                    ignore = {'W391'},
                    maxLineLength = 160
                }
            }
        }
    }
}
lc.hls.setup{}
lc.texlab.setup{}
