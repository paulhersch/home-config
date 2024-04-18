Map("t", "<ESC>", "<C-\\><C-n>", {})
Map("n", "QQ", ":wqa<CR>", {})
Map("i", "<C-H>", "<C-W>", {})

Map("n", "<Space>n", function ()
    vim.o.number = not vim.o.number
end)
