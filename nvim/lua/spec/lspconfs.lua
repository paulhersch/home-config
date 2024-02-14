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

local function dir_specific_settings(cwd, lc)
    local cwd_toplevel = vim.fn.substitute(cwd, '^.*/', '', '')
    -- lua
    lc.lua_ls.setup ({
        on_attach = function (client, _)
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
    'neovim/nvim-lspconfig',
    --dependencies = 'hrsh7th/cmp-nvim-lsp', --to set capabilities
    lazy = false, --is "lazy loaded" anyways
    config = function()
        local lc = require('lspconfig')
        --local util = require('lspconfig.util')

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
            settings = {
                pylsp = {
                    plugins = {
                        pycodestyle = {
                            -- flake8 does this
                            enabled = false,
                        },
                        jedi_completion = {
                            enabled = true,
                            include_params = true
                        },
                        flake8 = {
                            -- line too long from flake8
                            ignore = { "E501" },
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
                --enabled = { "bibtex", "context", "context.tex", "latex" }
            }}
        }
        lc.texlab.setup{
            settings = { texlab = { build = {
                executable = "lualatex"
            }}}
        }
        lc.rnix.setup{}
        lc.rust_analyzer.setup{}
        lc.nimls.setup{}
        lc.hls.setup{}
        lc.ccls.setup{}
    end,
    keys = {
        { "ss", "<cmd> lua vim.lsp.buf.signature_help()<cr>" },
        { "sr", '<cmd> lua vim.lsp.buf.document_highlight() vim.api.nvim_create_autocmd("CursorMoved", { callback = vim.lsp.buf.clear_references, once = true }) <cr>' }
    }
}
