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
        -- version = "11.x",
        priority = 1000,
        lazy = false
    },
    -- {
    --     "vhyrro/luarocks.nvim",
    --     priority = 1000,
    --     opts = { rocks = { "magick" } },
    --     lazy = false,
    -- },
    -- simply added the build thing to hsluv, no problems
    -- anything that needs compiling is available in nix
    {
        "hsluv/hsluv-lua",
        lazy = true,
        -- rocks are a pain on nix
        build = "mkdir lua && cp *.lua lua"
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
        },
    },
    change_detection = {
        enabled = false,
    },
    rocks = {
        enabled = false,
        server = "https://luarocks.org",
        hererocks = false
    },
    install = {
        colorscheme = { "readable_light" }
    },
    performance = {
        reset_packpath = true,
        rtp = {
            disabled_plugins = { "tutor", "netrwPlugin" }
        }
    },
})
