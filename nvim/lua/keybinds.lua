local function map(mode, lhs, rhs, opts) --stole this from some article
    local options = { noremap = true }
    if opts then
        options = vim.tbl_extend("force", options, opts)
    end
    vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end


map("n", "h", ":vertical resize +5 <CR>", { silent = true })
map("n", "j", ":resize -5 <CR>", { silent = true })
map("n", "k", ":resize +5 <CR>", { silent = true })
map("n", "l", ":vertical resize -5 <CR>", { silent = true })
map("t", "<ESC>", "<C-\\><C-n>", { silent = true })

map("n", "<leader><Enter>", "<cmd>Lspsaga open_floaterm <CR>", { silent = true })
map("n", "<leader><Esc>", "<cmd>Lspsaga close_floaterm<CR>", { silent = true})

map("n", "<leader>ca", "<cmd>Lspsaga code_action <CR>", { silent = true })
map("n", "gr", "<cmd>Lspsaga rename<cr>", {silent = true, noremap = true})
map("n", "K",  "<cmd>Lspsaga hover_doc<cr>", {silent = true, noremap = true})
map("n", "gd", "<cmd>Lspsaga preview_definition<CR>", {silent = true, noremap = true})
map("n", "gh", "<cmd>Lspsaga lsp_finder<CR>", {silent = true, noremap = true})
