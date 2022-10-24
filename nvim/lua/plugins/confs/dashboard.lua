return {
	'glepnir/dashboard-nvim',
	branch = 'master',
	config = function ()
		local db = require "dashboard"
		Map("n", "<Space>f", "<cmd>NvimTreeOpen <CR>", _)
		db.custom_center = {
			{
				icon = ' ',
				desc = 'Open Nvim Tree				 ',
				action = 'NvimTreeOpen',
				shortcut = 'SPC f'
			},
			{
				icon = ' ',
				desc = 'Find file with Telescope		',
				action = 'Telescope find_files',
				shortcut = 'ff'
			},
			{
				icon = ' ',
				desc = 'Live Grep with Telescope		',
				action = 'Telescope live_grep',
				shortcut = 'gf'
			}
		}
		db.custom_header = {
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
		}
		local handle = io.popen("fortune -s")
		if handle ~= nil then
			local quote = { "" }
			for line in handle:lines() do quote[#quote+1] = line end
			db.custom_footer = quote
			handle:close()
		else
			db.custom_footer = ""
		end
	end
}
