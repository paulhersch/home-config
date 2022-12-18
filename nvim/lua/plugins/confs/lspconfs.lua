return {
    'neovim/nvim-lspconfig',
    config = function()
        local lc = require('lspconfig')
		local util = require('lspconfig.util')

		Map("n", "ss", "<cmd> lua vim.lsp.buf.signature_help()<cr>", {})
		--local existing_capabilities = vim.lsp.protocol.make_client_capabilities()
		--util.default_config = vim.tbl_extend("force", util.default_config, {
		--	capabilities = require('cmp_nvim_lsp').default_capabilities(existing_capabilities),
		--})
		--vim.cmd([[echo 'running sumneko setup']])
		lc.sumneko_lua.setup ({
			on_new_config = function (config, root_dir)
				local short_root_dir = vim.fn.substitute(root_dir, '^.*/', '', '')
				--vim.cmd([[echo 'pwd: ]] .. short_root_dir .. [[']])
				if short_root_dir == "awesome" then
					--vim.cmd([[echo 'loading awm settings']])
					config = vim.tbl_deep_extend("force", config, {
						settings = { Lua = {
							runtime = "5.2",
							diagnostics = { globals = {
								"root", "awesome", "tag", "screen", "client",
								"modkey", "altkey", "mouse", "mousegrabber",
							}},
							workspace = { library = os.getenv("AWM_LIB_PATH")}
						}}
					})
				else if short_root_dir == "nvim" then
					--vim.cmd([[echo 'loading nvim settings']])
					config = vim.tbl_deep_extend("force", config, {
						settings = { Lua = {
							runtime = "LuaJIT",
							diagnostics = { globals = { "vim" }},
							workspace = { library = vim.api.nvim_get_runtime_file("", true)}
						}}
					})
					--vim.cmd([[echo 'which settings? ]] .. config.settings.Lua.runtime .. [[']])
				end end
			end,
			settings = {
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
        })
        lc.omnisharp.setup ({
            cmd = { "OmniSharp", "-lsp", "--hostPID", tostring(vim.fn.getpid()) }
        })
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
    end
}
