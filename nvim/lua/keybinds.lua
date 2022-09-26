Map("n", "h", ":vertical resize +5 <CR>", _)
Map("n", "j", ":resize -5 <CR>", _)
Map("n", "k", ":resize +5 <CR>", _)
Map("n", "l", ":vertical resize -5 <CR>", _)
Map("t", "<ESC>", "<C-\\><C-n>", _)

Map("n", "<leader><Enter>", "<cmd>FloatermShow<CR>", _)
Map("n", "<leader><Esc>", "<cmd>FloatermHide<CR>", _)

--Map("n", "gt", "<cmd>lua require('telescope.builtin').lsp_references()<CR>", _)
Map("n", "gf", "<cmd>Telescope live_grep<CR>", _)
Map("n", "ff", "<cmd>Telescope find_files<CR>", _)
Map("n", "gt", "<cmd>Lspsaga lsp_finder<CR>", _)
Map("n", "ca", "<cmd>Lspsaga code_action <CR>", _)
Map("n", "gr", "<cmd>Lspsaga rename <CR>", _)
Map("i", "<C-R>", "<cmd>Lspsaga rename <CR>", _)
Map("n", "gd", "<cmd>Lspsaga peek_definition <CR>", _)
--map("n", "D", "<cmd>Lspsaga show_line_diagnostics <CR>", _)
Map("n", "D", "<cmd>Lspsaga hover_doc <CR>", _)
Map("i", "<C-D>", "<cmd>Lspsaga diagnostic_jump_next <CR>", _)
Map("n", "<C-D>", "<cmd>Lspsaga diagnostic_jump_next <CR>", _)

--[[map("n", "gr", "<cmd>lua require('renamer').rename()<cr>", {silent = true, noremap = true})
map("n", "gd", "<cmd>lua require('goto-preview').goto_preview_definition()<CR>", {silent = true, noremap = true})
map("n", "gi", "<cmd>lua require('goto-preview').glsp_references(<CR>", {silent = true, noremap = true})
map("n", "K", "<cmd>lua vim.lsp.buf.hover()<cr>", {silent = true, noremap = true})
map("n", "D", "<cmd>lua vim.diagnostic.open_float()<cr>", {silent = true, noremap = true})]]
-- telescope search is nice
