-- german layout things, rebinding movement to home row
Map({"n", "x"}, "ö", "l", {})
Map({"n", "x"}, "l", "k", {})
Map({"n", "x"}, "k", "j", {})
Map({"n", "x"}, "j", "h", {})

Map("t", "<ESC>", "<C-\\><C-n>", {})
Map("n", "QQ", ":wqa<CR>", {})
Map("n", "ww", function ()
    vim.cmd(":wa")
    vim.notify("All Files saved", vim.log.levels.INFO, {
        title = "Saving"
    })
end, {})
Map("i", "<C-H>", "<C-W>", {})
