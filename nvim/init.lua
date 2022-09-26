function Map(mode, lhs, rhs, opts) --stole this from some article
    local options = { noremap = true }
    if opts then
        options = vim.tbl_extend("force", options, opts)
    end
    vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

require ("plugins")
require ("keybinds")
require ("options")
