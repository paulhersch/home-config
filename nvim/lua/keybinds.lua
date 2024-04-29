---comment stole this from some article, helps with mapping
---@param modes string | table mode/s as table or string
---@param key string the key(s) to map cmd to
---@param cmd string | function the function to bind this key to
---@param opts table? table of extra options, default is noremap and silent
local function map(modes, key, cmd, opts)
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

map("t", "<ESC>", "<C-\\><C-n>", {})
map("n", "QQ", ":wqa<CR>", {})
map("i", "<C-H>", "<C-W>", {})

map("n", "<Space>n", function()
    vim.wo[0].number = not vim.wo[0].number
end)

map("n", "t<Right>", "<cmd>:tabnext<cr>")
map("n", "t<Left>", "<cmd>:tabprev<cr>")
