Map("t", "<ESC>", "<C-\\><C-n>", {})
Map("n", "QQ", ":wqa<CR>", {})
Map("i", "<C-H>", "<C-W>", {})

Map("n", "<Space>n", function()
    vim.wo[0].number = not vim.wo[0].number
end)

Map("n", "t<Right>", "<cmd>:tabnext<cr>")
Map("n", "t<Left>", "<cmd>:tabprev<cr>")
