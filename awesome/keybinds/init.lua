local awful	= require ("awful")
local gears	= require ("gears")

local configdir	= gears.filesystem.get_configuration_dir()
local terminal = "kitty"
local filemanager = "pcmanfm"
local modkey = "Mod1"

local launcher = require ("ui.launcher")

require ("keybinds.clients").init(modkey)
-- General Awesome keys
awful.keyboard.append_global_keybindings({
	awful.key({ modkey, "Control" }, "r", awesome.restart,
		{description = "reload awesome", group = "awesome"}),
	awful.key({ modkey,           }, "Return", function () awful.spawn(terminal) end,
		{description = "open a terminal", group = "launcher"}),
    awful.key({ modkey }, "d", function() launcher.open() end,
		{description = "App launcher", group = "launcher"}),

	--awful.key({ modkey }, "d", function() awful.spawn("rofi -show combi -combi-modi drun,run") end,
	--	{description = "rofi", group = "launcher"}),
})

-- Focus related keybindings
awful.keyboard.append_global_keybindings({
	awful.key({ modkey,           }, "Up",
		function ()
			awful.client.focus.byidx(-1)
		end,
		{description = "focus in direction of master", group = "client"}),
	awful.key({ modkey,           }, "Down",
		function ()
			awful.client.focus.byidx( 1)
		end,
		{description = "focus away from master", group = "client"}),
})

-- Layout related keybindings
awful.keyboard.append_global_keybindings({
	awful.key({ modkey, "Shift"   }, "Down", function () awful.client.swap.byidx(  1) end,
		{description = "swap with next client by index", group = "client"}),
	awful.key({ modkey, "Shift"   }, "Up", function () awful.client.swap.byidx( -1) end,
		{description = "swap with previous client by index", group = "client"}),
	awful.key({ modkey,           }, "Right",     function () awful.tag.incmwfact( 0.05) end,
		{description = "increase master width factor", group = "layout"}),
	awful.key({ modkey,           }, "Left",     function () awful.tag.incmwfact(-0.05) end,
		{description = "decrease master width factor", group = "layout"}),
	awful.key({ modkey, "Shift"   }, "Left",     function () awful.tag.incnmaster( 1, nil, true) end,
		{description = "increase the number of master clients", group = "layout"}),
	awful.key({ modkey, "Shift"   }, "Right",     function () awful.tag.incnmaster(-1, nil, true) end,
		{description = "decrease the number of master clients", group = "layout"}),
	awful.key({ modkey, "Control" }, "Right",     function () awful.tag.incncol( 1, nil, true) end,
		{description = "increase the number of columns", group = "layout"}),
	awful.key({ modkey, "Control" }, "Left",     function () awful.tag.incncol(-1, nil, true) end,
		{description = "decrease the number of columns", group = "layout"}),
})

-- Tag related keybindings
awful.keyboard.append_global_keybindings({
	awful.key {
		modifiers   = { modkey },
		keygroup    = "numrow",
		description = "only view tag",
		group       = "tag",
		on_press    = function (index)
			local s = awful.screen.focused()
			local current = s.selected_tag
			--if not s.lasttag then s.lasttag = current end
			local tag = s.tags[index]
			--simple ws toggle like in i3
			if tag then
				if current == tag then --if double press cycle through screens and focus tags
                    local screens = {}
                    for sc in screen do screens[#screens+1] = sc end
                    local i
                    for j, v in ipairs(screens) do
                        if v == s then
                            i = j
                        end
                    end
                    print(i)
                    awful.screen.focus(i == #screens and screens[1] or screens[i+1])
                    awful.screen.focused().tags[index]:view_only()
					--s.lasttag:view_only()
				else --tag x, key for tag y
					tag:view_only()
				end
				--s.lasttag = current
			end
			collectgarbage("collect")
		end,
	},
	awful.key {
		modifiers = { modkey, "Shift" },
		keygroup    = "numrow",
		description = "move focused client to tag",
		group       = "tag",
		on_press    = function (index)
			if client.focus then
				local tag = client.focus.screen.tags[index]
				if tag then client.focus:move_to_tag(tag) end
			end
		end,
	},
})

-- Program shortcuts
awful.keyboard.append_global_keybindings({
	awful.key({ modkey }, "F3", function() awful.spawn.with_shell(filemanager) end),
	awful.key({}	, "Print", function() awful.spawn.with_shell(configdir .. "scripts/scrot") end),
	awful.key({modkey}, "Print", function() awful.spawn.with_shell(configdir .. "scripts/areascrot") end),
})

-- Media keys (for Laptops)
awful.keyboard.append_global_keybindings({
	awful.key({},	"XF86MonBrightnessUp", function() awful.spawn.with_shell("brightnessctl s +5%") end),
	awful.key({},	"XF86MonBrightnessDown", function() awful.spawn.with_shell("brightnessctl s 5%-") end),
	awful.key({},	"XF86AudioMute", function() awful.spawn.with_shell("pamixer -t") end),
	awful.key({},	"XF86AudioLowerVolume", function() awful.spawn.with_shell("pamixer -d 5") end),
	awful.key({},	"XF86AudioRaiseVolume", function() awful.spawn.with_shell("pamixer -i 5") end),
	awful.key({},	"XF86AudioPlay", function() awful.spawn.with_shell("playerctl -p spotify,ncspot play-pause") end),
	awful.key({},	"XF86AudioPrev", function() awful.spawn.with_shell("playerctl -p spotify,ncspot previous") end),
	awful.key({},	"XF86AudioNext", function() awful.spawn.with_shell("playerctl -p spotify,ncspot next") end),
})

local tabbed = require "plugins.bling.module.tabbed"

awful.keyboard.append_global_keybindings({
    awful.key({modkey},   "t", function ()
        local c = client.focus
        if c and c.bling_tabbed then
            tabbed.remove(c)
        else
            tabbed.init(c)
        end
        --tabbed.init(client.focus)
    end),
    awful.key({modkey},   "a", function () tabbed.pick() end)
})
