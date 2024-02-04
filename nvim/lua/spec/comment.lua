-- initally the config was much bigger because i wanted to add features
-- but i am too stupid to do what i want
return {
    'numToStr/Comment.nvim',
    config = function()
        require("Comment").setup({
                mappings = { basic = true, extra = false },
                opleader = {
                    line = "c"
                },
            })
    end,
    keys = {
        {"c", nil, mode = {"x", "n"}},
    }
}
