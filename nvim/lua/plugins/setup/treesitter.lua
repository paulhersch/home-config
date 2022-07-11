require("nvim-treesitter.configs").setup {
  	auto_install = true,
	sync_install = false,
	highlight = {
		enable = true,
		--disable = { "lua", "python", "c_sharp", "haskell" }, --i got language servers for those
		additional_vim_regex_highlighting = false,
	},
}
require("indent_blankline").setup {
    space_char_blankline = " ",
    show_current_context = true,
--    show_current_context_start = true,
}
