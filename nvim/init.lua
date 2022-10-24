--global func for easy access
---comment stole this from some article, helps with mapping
---@param mode string mode as single character
---@param key string the key(s) to map cmd to
---@param cmd string the function to bind this key to
---@param opts table table of extra options, default is noremap and silent
function Map(mode, key, cmd, opts)
	local options = { noremap = true, silent = true }
	if opts then
		options = vim.tbl_extend("force", options, opts)
	end
	vim.api.nvim_set_keymap(mode, key, cmd, options)
end

require ("plugins")
require ("keybinds")
require ("options")
