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
                runtime = "5.2",
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

local function dir_specific_settings(cwd, lc, on_attach_extra)
    local cwd_toplevel = vim.fn.substitute(cwd, '^.*/', '', '')
    on_attach_extra = on_attach_extra or function (_, _) end
    -- lua
    lc.lua_ls.setup ({
        on_attach = function (client, buf)
            on_attach_extra(client, buf)
            client.server_capabilities.semanticTokensProvider = nil
        end,
        settings=extend(
            "force",
            cwd_confs.lua.base,
            cwd_confs.lua[cwd_toplevel] or {}
        )
    })
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

            -- if we switch cwd: reload dir specific stuff
            local aug = vim.api.nvim_create_augroup("lspconf_extra", {clear = true})
            vim.api.nvim_create_autocmd("DirChangedPre", {
                group = aug,
                callback = function (event)
                    if not event.match == "global" then return end
                    vim.notify("reloading directory dependent lsp settings, this might take a while")
                    dir_specific_settings(event.file, lc)
                end
            })
            dir_specific_settings(vim.fn.getcwd(), lc)

            lc.omnisharp.setup ({
                cmd = { "OmniSharp" },
                on_attach = function (client, _)
                    client.server_capabilities.semanticTokensProvider = nil
                end,
                flags = {
                    debounce_text_changes = 150,
                }
            })

            -- ignore stupid "line too long" warning in python
            lc.pylsp.setup {
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
            }
            --shit server
            -- lc.jdtls.setup {
            --     cmd = { "jdt-language-server", "-configuration", os.getenv('HOME') .. "/.cache/jdtls/config", "-data", os.getenv('HOME') .. "/.cache/jdtls/workspace"}
            -- }
            --
            -- lc.java_language_server.setup {
            --     cmd = { "java-language-server" },
            --     root_dir = function(fname)
            --         local root = util.root_pattern('build.gradle', 'pom.xml', '.git', '.')(fname)
            --         if root then return root end
            --         return vim.fn.getcwd()
            --     end,
            -- }

            -- annoying for notes
            lc.ltex.setup{
                filetypes = { "bib", "context", "tex" },
                settings = { ltex = {
                    language = "de-DE",
                    enabled = { "bibtex", "context", "context.tex", "latex" }
                }}
            }
            lc.nil_ls.setup{}
            lc.rust_analyzer.setup{}
            lc.nimls.setup{}
            lc.hls.setup{}
            lc.ccls.setup{}
        end,
        keys = {
            { "ss", "<cmd> lua vim.lsp.buf.signature_help()<cr>" },
            { "sr", '<cmd> lua vim.lsp.buf.document_highlight() vim.api.nvim_create_autocmd("CursorMoved", { callback = vim.lsp.buf.clear_references, once = true }) <cr>' }
        }
    },
    {
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
            vim.g.vsnip_snippet_dir = os.getenv("HOME") .. "/.config/nvim/snips"
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
        'https://git.sr.ht/%7Ewhynothugo/lsp_lines.nvim',
        lazy = true,
        event = "LspAttach",
        name = "lsp_lines",
        config = function()
            --remove diagnostics at end of line
            vim.diagnostic.config({
                virtual_text = false
            })
            require("lsp_lines").setup()
        end
    },
    {
        'glepnir/lspsaga.nvim',
        branch = 'main',
        lazy = true,
        event = "LspAttach",
        config = function ()
            require('lspsaga').setup{
                diagnostic_header = { "✋", "👆", "👉", "🤏" },
                symbol_in_winbar = {
                    enable = true,
                    separator = '  ',
                    show_file = false,
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
