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
        priority = 1000,
        lazy = false
    },
    -- {
    --     "vhyrro/luarocks.nvim",
    --     priority = 1000,
    --     opts = { rocks = { "magick" } },
    --     lazy = false,
    -- },


    -- [[
    --  Luarocks dependencies/compiled stuff (rocks should work)
    -- ]]
    {
        "hsluv/hsluv-lua",
        lazy = true,
        -- rocks are a pain on nix
        -- build = "mkdir lua && cp *.lua lua"
    },
    {
        "leafo/magick",
        lazy = false
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
            "rockspec",
            "packspec"
        },
    },
    change_detection = {
        enabled = true,
    },
    rocks = {
        enabled = true,
        -- server = "https://luarocks.org",
        hererocks = nil
        -- should be able to install using luarocks
        -- python provider is installed, luajit is in neovims path, but somehow the installer
        -- for hererocks only finds lua 5.2???
    },
    install = {
        colorscheme = { "light" } -- should be available (local, cached)
    },
    performance = {
        reset_packpath = true,
        rtp = {
            disabled_plugins = { "tutor", "netrwPlugin" }
        }
    },
})
