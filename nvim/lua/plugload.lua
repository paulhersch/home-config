local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    {
        -- update self
        "folke/lazy.nvim",
        version = "11.x",
        priority = 1000,
        lazy = false
    },
    {
        "camspiers/luarocks",
        priority = 1000,
        opts = { rocks = { "hsluv" } },
        lazy = false,
    },
    { import = "spec" }
}, {
    dev = {
        enabled = true,
        path = vim.fn.stdpath("config") .. "/pkgs"
    },
    pkg = {
        enabled = true,
        versions = true,
        sources = {
            "lazy",
            "rockspec"
        },
    },
    change_detection = {
        enabled = false,
    },
    rocks = {
        server = "https://luarocks.org"
    },
    install = {
        colorscheme = { "light" }
    },
    performance = {
        reset_packpath = true,
        rtp = {
            disabled_plugins = { "tutor", "netrwPlugin" }
        }
    },
})
