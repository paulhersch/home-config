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

map("n", "<leader><Enter>", "<cmd>FloatermShow<CR>", { silent = true })
map("n", "<leader><Esc>", "<cmd>FloatermHide<CR>", { silent = true})

--map("n", "<leader>ca", "<cmd>Lspsaga code_action <CR>", { silent = true })
map("n", "gr", "<cmd>lua require('renamer').rename()<cr>", {silent = true, noremap = true})
map("n", "gd", "<cmd>lua require('goto-preview').goto_preview_definition()<CR>", {silent = true, noremap = true})
map("n", "gi", "<cmd>lua require('goto-preview').glsp_references(<CR>", {silent = true, noremap = true})
map("n", "gt", "<cmd>lua require('telescope.builtin').lsp_references()<CR>", {silent = true, noremap = true})
map("n", "K", "<cmd>lua vim.lsp.buf.hover()<cr>", {silent = true, noremap = true})
map("n", "D", "<cmd>lua vim.diagnostic.open_float()<cr>", {silent = true, noremap = true})
-- telescope search is nice
map("n", "gf", "<cmd>lua require('telescope.builtin').live_grep()<CR>", {silent = true, noremap = true})
