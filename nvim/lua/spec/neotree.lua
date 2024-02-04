return {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-tree/nvim-web-devicons",
        "MunifTanjim/nui.nvim",
        -- external sources
        "miversen33/netman.nvim",
        {
            -- fix for neotree api changes weren't merged (repo dead?)
            "idanarye/neo-tree-zk.nvim",
            branch = "fix-modified_buffers_changes-to-opened_buffers_changed"
        },
    },
    cmd = { "Neotree" },
    keys = {
        { "<Space>f", "<cmd>Neotree toggle source=last<CR>" }
    },
    config = function ()
        require("neo-tree").setup({
            sources = {
                "netman.ui.neo-tree",
                "filesystem",
                "git_status",
                "zk"
            },
            close_if_last_window = true,
            add_blank_line_at_top = true,
            hide_root_node = true,
            enable_git_status = true,
            enable_diagnostics = true,
            use_popups_for_input = false,
            source_selector = {
                winbar = true,
                tabs_layout = "equal",
                content_layout = "center",
                sources = {
                    {
                        source = "filesystem",
                        display_name = " "
                    },
                    {
                        source = "git_status",
                        display_name = " "
                    },
                    {
                        source = "remote",
                        display_name = " "
                    },
                    {
                        source = "zk",
                        display_name = " "
                    }
                },
                -- this gives the tabline a padded look (vert split is colored by neotree via hl)
                separator = { left = " ", right = "" },
                separator_active = { left = " ", right = "" },
                show_separator_on_edge = true,
                highlight_separator = "NeoTreeTabSeparator",
                highlight_separator_active = "NeoTreeTabSeparator",
            },
            default_component_configs = {
                indent = {
                    padding = 2,
                    expander_collapsed = "",
                    expander_expanded = "",
                },
                icon = {
                    folder_closed = "",
                    folder_open = "",
                    folder_empty = "",
                },
                modified = {
                    symbol = ""
                },
                name = {
                    use_git_status_colors = false,
                    highlight_opened_files = true
                },
                git_status = {
                    symbols = {
                        -- Change type
                        added     = "",
                        modified  = "",
                        deleted   = " ",
                        renamed   = " ",
                        -- Status type
                        untracked = " ",
                        ignored   = " ",
                        unstaged  = " ",
                        staged    = " ",
                        conflict  = " ",
                    },
                    align = "left"
                },
            },
            filesystem = {
                filtered_items = {
                    hide_dotfiles = false,
                    hide_gitignored = false,
                    show_hidden_count = false,
                    -- use_libuv_file_watcher = true,
                    hijack_netrw_behaviour = "open_default"
                }
            },
        })
    end
}
