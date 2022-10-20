return {
    'neovim/nvim-lspconfig',
    config = function()
        local cwd = vim.fn.substitute(vim.fn.getcwd(), '^.*/', '', '')
        local lc = require('lspconfig')
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
                        library = cwd == "awesome" and os.getenv("AWM_LIB_PATH") --[["/run/current-system/sw/share/awesome/lib"]] or (cwd == "nvim" and vim.api.nvim_get_runtime_file("", true) or nil),
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
        lc.rnix.setup{}
        lc.jdtls.setup {
            cmd = { "jdt-language-server" }
        }
    end
}
