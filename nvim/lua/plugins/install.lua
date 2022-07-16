local fn = vim.fn
local install_path = fn.stdpath "data" .. "/site/pack/packer/start/packer.nvim"

if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({'git', 'clone', '--depth=1', 'https://github.com/wbthomason/packer.nvim', install_path})
    vim.cmd "packadd packer.nvim"
    vim.cmd "PackerSync"
end

return require('packer').startup(function(use)
    use "wbthomason/packer.nvim"

    use {   'nvim-treesitter/nvim-treesitter',
        requires = 'tree-sitter/tree-sitter',
        run = ':TSUpdate'
    }
    use 'andweeb/presence.nvim'
    use 'nvim-lualine/lualine.nvim'
    use { 'lukas-reineke/indent-blankline.nvim',
        requires = 'nvim-treesitter/nvim-treesitter'
    }

    --colorschemes
    use 'sainnhe/everforest'
    use 'sainnhe/sonokai'
    use 'decaycs/decay.nvim'
    use 'cocopon/iceberg.vim'
    use 'ozkanonur/nimda.vim'
    use { 'Everblush/everblush.nvim', as = 'everblush' }
    use { 'folke/tokyonight.nvim', branch = 'main' }
    --adding IDE capabilities
    use 'neovim/nvim-lspconfig'
    use 'lewis6991/gitsigns.nvim'

    use {
        'filipdutescu/renamer.nvim',
        branch = 'master',
        requires = 'nvim-lua/plenary.nvim'
    }
    use { 'romgrk/barbar.nvim',
        requires = 'kyazdani42/nvim-web-devicons',
        config = function ()
            require('bufferline').setup{}
        end
    }

    use { 'rmagatti/goto-preview',
        config = function()
            require('goto-preview').setup {}
        end
    }

    use { 'nvim-telescope/telescope.nvim',
        tag = '0.1.0',
        requires = { {'nvim-lua/plenary.nvim'} }
    }

    use 'voldikss/vim-floaterm'

    use { 'hrsh7th/nvim-cmp',
        requires = {
            'hrsh7th/cmp-nvim-lsp',
            'hrsh7th/cmp-path',
            'hrsh7th/cmp-buffer',
            'saadparwaiz1/cmp_luasnip',
            'L3MON4D3/LuaSnip'
        }
    }

    use { 'folke/trouble.nvim',
        requires = {'folke/lsp-colors.nvim'}
    }

    use { 'kyazdani42/nvim-tree.lua',
        requires = { 'kyazdani42/nvim-web-devicons' }
    }
end)
