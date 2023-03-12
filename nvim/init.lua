--global func for easy access
---comment stole this from some article, helps with mapping
---@param modes string | table mode/s as table or string
---@param key string the key(s) to map cmd to
---@param cmd string | function the function to bind this key to
---@param opts table? table of extra options, default is noremap and silent
function Map(modes, key, cmd, opts)
	local options = { noremap = true, silent = true }
	if opts then
		options = vim.tbl_extend("force", options, opts)
	end
    if type(modes) == "string" then
	    vim.keymap.set(modes, key, cmd, options)
    else
        for _, mode in ipairs(modes) do
            vim.keymap.set(mode, key, cmd, options)
        end
    end
end

require("keybinds")
require("options")
require("plugins")
