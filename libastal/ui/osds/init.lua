require "ui.osds.notifications".setup()

return {
    unload = function()
        require "ui.osds.notifications".unload()
    end
}
