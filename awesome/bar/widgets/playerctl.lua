local pctl	= require("lgi").Playerctl
local wibox = require("wibox")

local manager = pctl.PlayerManager()
local playerWidgets = {}

local function create_widget_with_signals(player)
	local widget = wibox.widget {
		widget = wibox.widget.textbox,
		text = player.get_title()
	}
	player.on_metadata = function (_,meta)
		widget.text = meta.value['xesam:title']
	end
	return widget
end

local container_widget = wibox.widget {
	layout = wibox.layout.fixed.vertical,
	playerWidgets
}

manager.on_name_appeared = function(self, pname, _)
	local newPlayer = pctl.Player.new_from_name(pname)
	self:manage_player(newPlayer)
	playerWidgets = create_widget_with_signals(newPlayer)
end

return container_widget
