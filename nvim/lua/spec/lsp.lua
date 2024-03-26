local extend = vim.tbl_extend

local cwd_confs = {
    lua = {
        base = {
            Lua = {
                runtime = "Lua5.2",
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
        awesome = {
            Lua = {
                runtime = "LuaJIT",
                diagnostics = { globals = {
                    "root", "awesome", "tag", "screen", "client",
                    "modkey", "altkey", "mouse", "mousegrabber",
                }},
                workspace = { library = { os.getenv("AWM_LIB_PATH") }}
            }
        },
        nvim = {
            Lua = {
                runtime = "LuaJIT",
                diagnostics = { globals = { "vim" }},
                workspace = { library = vim.api.nvim_get_runtime_file("", true)}
            }
        }
    }
}

local function dir_specific_lsps(cwd, lc, defaults)
    local cwd_toplevel = vim.fn.substitute(cwd, '^.*/', '', '')
    -- lua
    lc.lua_ls.setup (
        extend("force", defaults, {
            settings=extend(
                "force",
                cwd_confs.lua.base,
                cwd_confs.lua[cwd_toplevel] or {}
            )
        })
    )
end

return {
    {
        'neovim/nvim-lspconfig',
        dependencies = {
            'lukas-reineke/lsp-format.nvim'
        },
        lazy = false,
        config = function()
            local lc = require('lspconfig')

            local lf = require("lsp-format")
            lf.setup {}

            local function format_attach(client, buf)
                lf.on_attach(client, buf)
            end

            local default_lsp = {
                capabilities = {
                    textDocument = {
                        completion = {
                            completionItem = {
                                snippetSupport = false
                            }
                        }
                    },
                    semanticTokensProvider = nil
                }
            }

            -- if we switch cwd: reload dir specific stuff
            local aug = vim.api.nvim_create_augroup("lspconf_extra", {clear = true})
            vim.api.nvim_create_autocmd("DirChangedPre", {
                group = aug,
                callback = function (event)
                    if not event.match == "global" then return end
                    vim.notify("reloading directory dependent lsp settings, this might take a while")
                    dir_specific_lsps(event.file, lc, default_lsp)
                end
            })
            dir_specific_lsps(vim.fn.getcwd(), lc, default_lsp)

            local confs = {
                nil_ls = {},
                rust_analyzer = {},
                hls = {},
                ccls = {},
                quick_lint_js = {},
                pylsp = {
                    on_attach = format_attach,
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
                                }
                            }
                        }
                    }
                },
                ltex = {
                    -- annoying for notes, disabling md
                    filetypes = { "context", "tex" },
                    settings = { ltex = {
                        language = "de-DE",
                        enabled = { "context", "context.tex", "latex" }
                    }}
                },
                -- omnisharp = {
                --     cmd = { "OmniSharp" },
                --     flags = {
                --         debounce_text_changes = 150,
                --     }
                -- }
            }

            for lang, conf in pairs(confs) do
                lc[lang].setup(extend("force", default_lsp, conf))
            end
        end,
        keys = {
            { "ss", "<cmd> lua vim.lsp.buf.signature_help()<cr>" },
            { "sr", '<cmd> lua vim.lsp.buf.document_highlight() vim.api.nvim_create_autocmd("CursorMoved", { callback = vim.lsp.buf.clear_references, once = true }) <cr>' }
        }
    },
    {
        'L3MON4D3/LuaSnip',
        dependencies = {
            'rafamadriz/friendly-snippets',
        },
        config = function ()
            require('luasnip.loaders.from_vscode').lazy_load()
        end
    },
    {
        'hrsh7th/nvim-cmp',
        dependencies = {
            -- sources and functionality
            'hrsh7th/cmp-nvim-lsp',
            'hrsh7th/cmp-path',
            'hrsh7th/cmp-buffer',
            'hrsh7th/cmp-cmdline',
            'hrsh7th/cmp-nvim-lsp-signature-help',
            -- snippets
            'L3MON4D3/LuaSnip',
            'saadparwaiz1/cmp_luasnip',
            -- for bracket completion
            'windwp/nvim-autopairs'
        },
        event = "LspAttach",
        config = function()
            local cmp = require("cmp")
            local luasnip = require("luasnip")
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
                sources = cmp.config.sources({{ name = 'path' }}, {
                    {
                        name = 'cmdline',
                        option = {
                            ignore_cmds = { 'Man' }
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
                            vim_item.kind = " " .. (cmp_kinds[vim_item.kind] or " _ ") .. " "
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
                        elseif luasnip.expandable() or luasnip.jumpable() then
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
                        entry_filter = function (entry)
                            -- ignore Text and Snippet suggestions from LSPs
                            -- Text = 1, Snippet = 15
                            -- simpler than overwriting every single lspconfig setup call
                            local type = entry:get_kind()
                            return type ~= 1 and type ~= 15
                        end
                    },
                    { name = 'path' },
                    { name = 'luasnip' },
                    { name = 'nvim_lsp_signature_help' }
                },
            })
            cmp.event:on (
                'confirm_done',
                cmp_autopair.on_confirm_done()
            )
        end
    },
    {
        'stevearc/aerial.nvim',
        dependencies = {
            'nvim-treesitter/nvim-treesitter'
        },
        config = function ()
            require('aerial').setup{}
        end,
        keys = {
            { "<Space>a", "<cmd>AerialToggle<cr>" }
        }
    },
    {
        'glepnir/lspsaga.nvim',
        branch = 'main',
        lazy = true,
        event = "LspAttach",
        config = function ()
            require('lspsaga').setup{
                symbol_in_winbar = {
                    enable = false,
                },
                lightbulb = {
                    enable = false,
                    enable_in_insert = false,
                    virtual_text = false
                },
                ui = {
                    border = "solid"
                }
            }
        end,
        keys = {
            { "ca", "<cmd>Lspsaga code_action <CR>" },
            { "gr", "<cmd>Lspsaga rename <CR>" },
            { "<C-R>", "<cmd>Lspsaga rename <CR>", mode = "i" },
            { "gd", "<cmd>Lspsaga peek_definition <CR>" },
            { "D", "<cmd>Lspsaga hover_doc <CR>" },
            { "<C-D>", "<cmd>Lspsaga diagnostic_jump_next <CR>", mode = {"i", "n"}}
        }
    },
}
