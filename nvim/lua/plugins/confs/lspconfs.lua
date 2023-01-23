return {
    'neovim/nvim-lspconfig',
    requires = 'hrsh7th/cmp-nvim-lsp', --to set capabilities
    config = function()
        local lc = require('lspconfig')
        local util = require('lspconfig.util')

        Map("n", "ss", "<cmd> lua vim.lsp.buf.signature_help()<cr>", {})
        Map("n", "sr", '<cmd> lua vim.lsp.buf.document_highlight(); vim.api.nvim_create_autocmd("CursorMoved", { callback = vim.lsp.buf.clear_references, once = true }) <cr>', {})

        local short_root_dir = vim.fn.substitute(vim.fn.getcwd(), '^.*/', '', '')
        --somehow the sumneko setup with workspaces only works properly when i run stuff at startup not at runtime, so this has to do for now
        local lua_conf = {
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
            }
        if short_root_dir == "awesome" then
            lua_conf = vim.tbl_deep_extend("force", lua_conf, {
                Lua = {
                    runtime = "5.2",
                    diagnostics = { globals = {
                        "root", "awesome", "tag", "screen", "client",
                        "modkey", "altkey", "mouse", "mousegrabber",
                    }},
                    workspace = { library = { os.getenv("AWM_LIB_PATH") }}
                }
            })
        end
        if short_root_dir == "nvim" then
            lua_conf = vim.tbl_deep_extend("force", lua_conf, {
                Lua = {
                    runtime = "LuaJIT",
                    diagnostics = { globals = { "vim" }},
                    workspace = { library = vim.api.nvim_get_runtime_file("", true)}
                }
            })
        end
        lc.sumneko_lua.setup ({settings=lua_conf})

        lc.omnisharp.setup ({
            cmd = { "OmniSharp", "-lsp", "--hostPID", tostring(vim.fn.getpid()) }
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
        lc.jdtls.setup {
            cmd = { "jdt-language-server", "-configuration", os.getenv('HOME') .. "/.cache/jdtls/config", "-data", os.getenv('HOME') .. "/.cache/jdtls/workspace"}
        }

        lc.java_language_server.setup {
            cmd = { "java-language-server" },
            root_dir = function(fname)
                local root = util.root_pattern('build.gradle', 'pom.xml', '.git', '.')(fname)
                if root then return root end
                return vim.fn.getcwd()
            end,
        }

        lc.ltex.setup{}
        lc.hls.setup{}
        lc.texlab.setup{}
        lc.rnix.setup{}
    end
}
