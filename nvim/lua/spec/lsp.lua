local extend = vim.tbl_extend
local a = vim.api

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

local inlay_hints_by_ft = {
    latex = false
}

local cwd_confs = {
    lua = {
        base = {
            Lua = {
                runtime = { version = "LuaJIT" },
                workspace = {
                    checkThirdParty = false,
                },
                completion = {
                    callSnippet = { Both = true },
                    keywordSnippet = { Both = true }
                },
                telemetry = { enable = false },
            }
        },
        -- NixOS doesn't expose AWMs library path, so i have to read that one from an env var (which is not possible
        -- to do with the luarc.json -> ugly hack depending on root folder)
        awesome = function()
            return {
                Lua = {
                    runtime = "LuaJIT",
                    diagnostics = {
                        globals = {
                            "root", "awesome", "tag", "screen", "client",
                            "modkey", "altkey", "mouse", "mousegrabber",
                        }
                    },
                    workspace = { library = { os.getenv("AWM_LIB_PATH") } }
                }
            }
        end,
        nvim = function()
            return {
                Lua = {
                    runtime = { version = "LuaJIT" },
                    diagnostics = { globals = { "vim" } },
                    workspace = { library = vim.api.nvim_get_runtime_file("", true) }
                }
            }
        end
    }
}

local function dir_specific_lsps(cwd, lc, defaults)
    local cwd_toplevel = vim.fn.substitute(cwd, '^.*/', '', '')
    -- lua
    lc.lua_ls.setup(
        extend("force", defaults, {
            settings = extend(
                "force",
                cwd_confs.lua.base,
                cwd_confs.lua[cwd_toplevel] and cwd_confs.lua[cwd_toplevel]() or {}
            )
        })
    )
end

local lsp_buf_keybinds = {
    { "ss",    vim.lsp.buf.signature_help },
    -- highlight use and clear highlights after moving cursor
    { "sr", function()
        vim.lsp.buf.document_highlight()
        vim.api.nvim_create_autocmd("CursorMoved", {
            callback = vim.lsp.buf.clear_references,
            once = true
        })
    end
    },
    { "D",     vim.lsp.buf.hover },
    { "gr",    vim.lsp.buf.rename },
    { "gq",    vim.lsp.buf.format },
    { "gd",    function() require("telescope.builtin").lsp_definitions() end },
    { "<C-R>", vim.lsp.buf.rename,                                           mode = "i" },
    { "H",     vim.diagnostic.open_float },
    { "<C-D>", vim.diagnostic.goto_next }
}

a.nvim_create_autocmd("LspAttach", {
    callback = function(args)
        local buf = args.buf
        local succ, res = pcall(a.nvim_buf_get_var, buf, "lsp_buf_keybinds_added")
        if not succ or not res then
            for _, bind in ipairs(lsp_buf_keybinds) do
                vim.keymap.set(
                    bind["mode"] or "n",
                    bind[1],
                    bind[2],
                    { buffer = buf, silent = true }
                )
            end
            a.nvim_buf_set_var(buf, "lsp_buf_keybinds_added", true)
        end
    end
})

a.nvim_create_autocmd("LspDetach", {
    callback = function(args)
        local buf = args.buf
        -- delete keymaps for lsp if all but the client that is about to detach
        -- is connected on the buf
        local succ, res = pcall(a.nvim_buf_get_var, buf, "lsp_buf_keybinds_added")
        if succ and res and not (#vim.lsp.get_clients({ bufnr = buf }) >= 2) then
            for _, bind in ipairs(lsp_buf_keybinds) do
                vim.keymap.del(
                    bind["mode"] or "n",
                    bind[1],
                    { buffer = buf, silent = true }
                )
            end
            a.nvim_buf_set_var(buf, "lsp_buf_keybinds_added", false)
        end
    end
})

return {
    {
        "lukas-reineke/lsp-format.nvim",
        lazy = true,
        opts = {}
    },
    {
        'neovim/nvim-lspconfig',
        dependencies = {
            'lukas-reineke/lsp-format.nvim'
        },
        event = "VeryLazy",
        config = function()
            -- overwrite default window border style for popups
            local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
            function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
                opts = opts or {}
                opts.border = "single"
                return orig_util_open_floating_preview(contents, syntax, opts, ...)
            end

            local function default_attach(client, buf)
                -- dont attach keybinds for lsp stuff here, as we will add them when LspAttach fires
                if inlay_hints_by_ft[vim.filetype.match({ buf = vim.api.nvim_get_current_buf() })] then
                    vim.lsp.inlay_hint.enable(true, { bufnr = 0 })
                else
                    vim.lsp.inlay_hint.enable(false, { bufnr = 0 })
                end

                require("lsp-format").on_attach(client, buf)
            end

            local default_settings = {
                on_attach = default_attach,
                capabilities = vim.lsp.protocol.make_client_capabilities()
            }

            -- extend table with activated servers
            local configs = (function()
                local confs = {
                    nil_ls = {},
                    rust_analyzer = {},
                    hls = {},
                    ccls = {},
                    ts_ls = {},
                    bashls = {},
                    -- texlab = {},
                    gopls = {},
                    pylsp = {
                        settings = {
                            pylsp = {
                                plugins = {
                                    jedi_completion = {
                                        enabled = true,
                                        include_params = true
                                    },
                                    ruff = {
                                        enabled = true,
                                        formatEnabled = false
                                    },
                                    black = {
                                        enabled = true
                                    },
                                    mypy = {
                                        enabled = true,
                                        live_mode = false,
                                        dmypy = true,
                                    }
                                }
                            }
                        }
                    },
                    ltex = {
                        -- annoying for notes, disabling md
                        filetypes = { "context", "tex" },
                        settings = {
                            ltex = {
                                language = "de-DE",
                                enabled = { "context", "context.tex", "latex" }
                            }
                        }
                    },
                    -- omnisharp = {
                    --     cmd = { "OmniSharp" },
                    --     flags = {
                    --         debounce_text_changes = 150,
                    --     }
                    -- }
                }

                for lang, conf in pairs(confs) do
                    confs[lang] = extend("force", default_settings, conf)
                end
                return confs
            end)()

            local function do_setup()
                dir_specific_lsps(vim.fn.getcwd(), require('lspconfig'), default_settings)
                for lang, conf in pairs(configs) do
                    require('lspconfig')[lang].setup(conf)
                end
            end
            -- if we switch cwd: reload dir specific stuff
            -- lsps need libs from projects, so if direnv isn't loaded they are practically useless
            local aug = vim.api.nvim_create_augroup("lspconf_extra", { clear = true })
            vim.api.nvim_create_autocmd("User", {
                group = aug,
                pattern = "DirenvLoaded",
                callback = do_setup
            })
            do_setup()
        end,
    },
    {
        'aznhe21/actions-preview.nvim',
        dependencies = "neovim/nvim-lspconfig",
        keys = {
            { "<leader>ca", function() require("actions-preview").code_actions() end, mode = { "n", "v" }, silent = true }
        }
    },
    {
        'L3MON4D3/LuaSnip',
        lazy = true,
        build = "make install_jsregexp",
        dependencies = {
            'rafamadriz/friendly-snippets',
        },
        config = function()
            local vs_loader = require('luasnip.loaders.from_vscode')
            vs_loader.lazy_load() -- load friendly snippets
            vs_loader.lazy_load({ paths = { './snips' } })
        end,
    },
    -- {
    --     'ludovicchabant/vim-gutentags',
    --     lazy = false
    -- },
    {
        'hrsh7th/nvim-cmp',
        dependencies = {
            -- sources and functionality
            'hrsh7th/cmp-nvim-lsp',
            'hrsh7th/cmp-path',
            'hrsh7th/cmp-cmdline',
            --'hrsh7th/cmp-buffer',
            'hrsh7th/cmp-nvim-lsp-signature-help',
            -- optional sources, used by ftplugins
            'kdheepak/cmp-latex-symbols',
            'micangl/cmp-vimtex',
            'hrsh7th/cmp-emoji',
            -- snippets
            'L3MON4D3/LuaSnip',
            'saadparwaiz1/cmp_luasnip',
        },
        event = "VeryLazy",
        config = function()
            local cmp = require("cmp")
            local luasnip = require("luasnip")

            cmp.setup.cmdline(':', {
                mapping = cmp.mapping.preset.cmdline(),
                sources = {
                    {
                        name = 'path'
                    },
                    {
                        name = 'cmdline',
                        option = {
                            ignore_cmds = { 'Man' }
                        }
                    }
                }
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
                    format = function(entry, vim_item)
                        if vim_item.kind ~= nil then
                            if entry.source.name == "vimtex" then
                                -- only show right side info stuff, as every entry is reported with
                                -- kind Text anyways
                                vim_item.kind = ""
                                vim_item.menu = "    (" .. vim_item.kind .. ")"
                            elseif entry.source.name == "emoji" then
                                -- dont show anything (its just text)
                                vim_item.kind = ""
                                vim_item.menu = ""
                            else
                                -- fancy default
                                -- glyph with highlights, entry name thing, kind name
                                vim_item.menu = "    (" .. vim_item.kind .. ")"
                                vim_item.kind = " " .. (cmp_kinds[vim_item.kind] or " _ ") .. " "
                            end
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
                    {
                        name = 'nvim_lsp',
                        entry_filter = function(entry)
                            -- ignore Text and Snippet suggestions from LSPs
                            -- Text = 1, Snippet = 15
                            -- simpler than overwriting every single lspconfig setup call
                            local type = entry:get_kind()
                            return type ~= 1 and type ~= 15
                        end
                    },
                    { name = 'path' },
                    { name = 'luasnip' },
                    { name = 'nvim_lsp_signature_help' },
                },
            })
        end
    },
    {
        'stevearc/aerial.nvim',
        lazy = true,
        dependencies = {
            'nvim-treesitter/nvim-treesitter'
        },
        config = function()
            require('aerial').setup {
                nav = {
                    border = "single",
                    win_opts = { winblend = 0 },
                    keymaps = {
                        ["<Left>"] = "actions.left",
                        ["<Right>"] = "actions.right",
                        ["q"] = "actions.close",
                        ["<esc>"] = "actions.close"
                    }
                }
            }
            require("telescope").load_extension("aerial")
        end,
        keys = {
            { "<Space>a", function() require("telescope").extensions.aerial.aerial() end, silent = true },
            { "<C-a>",    function() require("aerial").nav_toggle() end,                  silent = true }
        }
    },
}
