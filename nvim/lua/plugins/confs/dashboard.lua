return {
	'glepnir/dashboard-nvim',
	branch = 'master',
    lazy = false,
    --event = 'VimEnter',
    config = function ()
        require "dashboard".setup({
            theme = 'doom',
            config = {
                center = {
                    {
                        icon = '   ',
                        desc = 'Load directory session          ',
                        action = 'SessionManager load_current_dir_session',
                        --key = 'fs'
                    },
                    {
                        icon = '   ',
                        desc = 'Open Nvim Tree               ',
                        action = 'NvimTreeToggle',
                        key = 'SPC f'
                    },
                    {
                        icon = '   ',
                        desc = 'Find file with Telescope        ',
                        action = 'Telescope find_files',
                        key = 'ff'
                    },
                    {
                        icon = '   ',
                        desc = 'Live Grep with Telescope        ',
                        action = 'Telescope live_grep',
                        key = 'gf'
                    }, 
                },
                header = {
                    [[=================     ===============     ===============   ========  ========]],
                    [[\\ . . . . . . .\\   //. . . . . . .\\   //. . . . . . .\\  \\. . .\\// . . //]],
                    [[||. . ._____. . .|| ||. . ._____. . .|| ||. . ._____. . .|| || . . .\/ . . .||]],
                    [[|| . .||   ||. . || || . .||   ||. . || || . .||   ||. . || ||. . . . . . . ||]],
                    [[||. . ||   || . .|| ||. . ||   || . .|| ||. . ||   || . .|| || . | . . . . .||]],
                    [[|| . .||   ||. _-|| ||-_ .||   ||. . || || . .||   ||. _-|| ||-_.|\ . . . . ||]],
                    [[||. . ||   ||-'  || ||  `-||   || . .|| ||. . ||   ||-'  || ||  `|\_ . .|. .||]],
                    [[|| . _||   ||    || ||    ||   ||_ . || || . _||   ||    || ||   |\ `-_/| . ||]],
                    [[||_-' ||  .|/    || ||    \|.  || `-_|| ||_-' ||  .|/    || ||   | \  / |-_.||]],
                    [[||    ||_-'      || ||      `-_||    || ||    ||_-'      || ||   | \  / |  `||]],
                    [[||    `'         || ||         `'    || ||    `'         || ||   | \  / |   ||]],
                    [[||            .===' `===.         .==='.`===.         .===' /==. |  \/  |   ||]],
                    [[||         .=='   \_|-_ `===. .==='   _|_   `===. .===' _-|/   `==  \/  |   ||]],
                    [[||      .=='    _-'    `-_  `='    _-'   `-_    `='  _-'   `-_  /|  \/  |   ||]],
                    [[||   .=='    _-'          '-__\._-'         '-_./__-'         `' |. /|  |   ||]],
                    [[||.=='    _-'                                                     `' |  /==.||]],
                    [[=='    _-'                        N E O V I M                         \/   `==]],
                    [[\   _-'                                                                `-_   /]],
                    [[ `''                                                                       ``']],
                    [[                                                                              ]],
                },
                --[[local handle = io.popen("fortune -s")
        if handle ~= nil then
            local quote = { "" }
            for line in handle:lines() do quote[#quote+1] = line end
            db.custom_footer = quote
            handle:close()
        else
            db.custom_footer = ""
                end]]
            }})
    end
}
