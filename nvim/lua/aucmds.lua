-- https://powersnail.com/2024/open-binary-files-external/
-- this instantly deletes a buffer when opening a pdf and opens the file in a
-- viewer appropriately chosen via the xdg spec
vim.api.nvim_create_autocmd("BufReadCmd", {
    pattern = { "*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp", "*.pdf" },
    callback = function()
        local filename = vim.fn.shellescape(vim.api.nvim_buf_get_name(0))
        vim.cmd("silent !xdg-open " .. filename .. " &")
        vim.cmd("let tobedeleted = bufnr('%') | b# | exe \"bd! \" . tobedeleted")
    end
})
