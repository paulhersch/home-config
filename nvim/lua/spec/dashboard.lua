return {
	'glepnir/dashboard-nvim',
	branch = 'master',
    lazy = false,
    --event = 'VimEnter',
    config = function ()
        require "dashboard".setup({
            theme = 'doom',
            hide = {
                statusline = false,
                tabline = false,
                winbar = false
            },
            config = {
                center = {
                    {
                        icon = '   ',
                        desc = 'Open Zettelkasten               ',
                        action = 'Neotree toggle source=zk'
                    },
                    {
                        icon = '   ',
                        desc = 'Edit config                     ',
                        action = 'cd ' .. os.getenv('HOME') .. "/.config/nvim | e " .. os.getenv('HOME') .. "/.config/nvim/init.lua"
                    },
                    {
                        icon = '   ',
                        desc = 'Open Tree                    ',
                        action = 'Neotree toggle',
                        key = 'SPC f'
                    },
                    {
                        icon = '   ',
                        desc = 'Find file in cwd                ',
                        action = 'Telescope find_files',
                        key = 'ff'
                    },
                    {
                        icon = '   ',
                        desc = 'Live Grep in cwd                ',
                        action = 'Telescope live_grep',
                        key = 'gf'
                    },
                },
                header = {
                    [[       ,                              ]],
                    [[       \`-._           __             ]],
                    [[        \\  \-..____,.'  `.           ]],
                    [[         :  )       :      :\         ]],
                    [[          ;'        '   ;  | :        ]],
                    [[          )..      .. .:.`.; :        ]],
                    [[         /::...  .:::...   ` ;        ]],
                    [[         `:o>   /\o_>        : `.     ]],
                    [[        `-`.__ ;   __..--- /:.   \    ]],
                    [[        === \_/   ;=====_.':.     ;   ]],
                    [[         ,/'`--'...`--....        ;   ]],
                    [[              ;                    ;  ]],
                    [[          . '                       ; ]],
                    [[        .'     ..     ,      .       ;]],
                    [[       :       ::..  /      ;::.     |]],
                    [[      /      `.;::.  |       ;:..    ;]],
                    [[     :         |:.   :       ;:.    ; ]],
                    [[     :         ::     ;:..   |.    ;  ]],
                    [[      :       :;      :::....|     |  ]],
                    [[      /\     ,/ \      ;:::::;     ;  ]],
                    [[    .:. \:..|    :     ; '.--|     ;  ]],
                    [[   ::.  :''  `-.,,;     ;'   ;     ;  ]],
                    [[.-'. _.'\      / `;      \,__:      \ ]],
                    [[`---'    `----'   ;      /    \,.,,,/ ]],
                    [[                   `----`             ]]
                }
            }})
    end
}
