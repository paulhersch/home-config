local gears	= require("gears")
local cairo = require("lgi").cairo

--typesafe function overloader (copied from lua-users.org) {{{
--source: http://lua-users.org/wiki/OverloadedFunctions
local function overloaded()
        local fns = {}
        local mt = {}
        local function oerror()
            return error("Invalid argument types to overloaded function")
        end
        function mt:__call(...)
            local signature = {}
            for i,arg in ipairs {...} do
                signature[i] = type(arg)
            end
            signature = table.concat(signature, ",")
            return (fns[signature] or self.default)(...)
        end
        function mt:__index(key)
            local signature = {}
            local function __newindex(_, key, value)
                signature[#signature+1] = key
                fns[table.concat(signature, ",")] = value
            end
            local function __index(_, key)
                signature[#signature+1] = key
                return setmetatable({}, { __index = __index, __newindex = __newindex })
            end
            return __index(self, key)
        end
        function mt:__newindex(key, value)
            fns[key] = value
        end
        return setmetatable({ default = oerror }, mt)
    end
--}}}

local function dec_hex(IN)
    local B,K,OUT,I,D=16,"0123456789ABCDEF","",0,nil
    while IN>0 do
        I=I+1
        IN,D=math.floor(IN/B),(IN%B)+1
        OUT=string.sub(K,D,D)..OUT
    end
    return #OUT == 2 and OUT or "0" .. OUT
end

-- color helpers {{{
local color = {}

color.col_shift = overloaded()
color.col_shift.string.number = function(c, s)
	local r,g,b,o = gears.color.parse_color(c)
	return "#" .. dec_hex(r*255+s)
		.. dec_hex(g*255+s)
		.. dec_hex(b*255+s)
		.. dec_hex(o*255)
end
color.col_shift.string.number.number.number = function(c,sr,sg,sb)
	local r,g,b,o = gears.color.parse_color(c)
	return "#" .. dec_hex(r*255+sr)
		.. dec_hex(g*255+sg)
		.. dec_hex(b*255+sb)
		.. dec_hex(o*255)
end
color.col_shift.string.number.number.number.number = function(c,sr,sg,sb,so)
	local r,g,b,o = gears.color.parse_color(c)
	return "#" .. dec_hex(r*255+sr)
		.. dec_hex(g*255+sg)
		.. dec_hex(b*255+sb)
		.. dec_hex(o*255+so)
end

color.col_diff = function(f, s)
	local fr, fg, fb, fo = gears.color.parse_color(f)
	local sr, sg, sb, so = gears.color.parse_color(s)
	return sr-fr,sg-fg,sb-fb,so-fo
end
color.col_mix = function(f, s)
    local r,g,b,o = color.col_diff(f,s)
    return color.col_shift(f,r*128,g*128,b*128,o*128)
end
--}}}

local function cursor_focus(widget, wibox, cursor)
        widget:connect_signal("mouse::enter", function()
    	    wibox = wibox or mouse.current_wibox
            wibox.cursor = cursor
	    end)
	    widget:connect_signal("mouse::leave", function()
    	    wibox = wibox or mouse.current_wibox
		    wibox.cursor = "left_ptr"
	    end)
    return widget
end

local function pointer_on_focus(widget, wibox)
    return cursor_focus(widget, wibox, "hand1")
end

local function textcursor_on_focus(widget, wibox)
    return cursor_focus(widget, wibox, "xterm")
end


local ceil = math.ceil
-- copied from PR 3776
---crops surface with offsets or target ratio (or both)
---@diagnostic disable-next-line: undefined-doc-name
---@param args {surface: surface, ratio: number, left: number, right: number, top: number, bottom: number}
---@diagnostic disable-next-line: undefined-doc-name
---@return surface|nil
local function crop_surface(args)
    args = args or {}

    if not args.surface then
        error("No surface to crop_surface supplied")
        return nil
    end

    local surf = args.surface
    local target_ratio = args.ratio

    local w, h = gears.surface.get_size(surf)
    local offset_w, offset_h =  0, 0

    if (args.top or args.right or args.bottom or args.left) then
        local left = args.left or 0
        local right = args.right or 0
        local top = args.top or 0
        local bottom = args.bottom or 0

        if (top < 0 or right < 0 or bottom < 0 or left < 0) then
            error("negative offsets are not supported for crop_surface")
        end

        w = w - left - right
        h = h - top - bottom

        -- the offset needs to be negative
        offset_w = - left
        offset_h = - top

        -- breaking stuff with cairo crashes awesome with no way to restart in place
        -- so here are checks for user error
        if w <= 0 or h <= 0 then
            error("Area to remove cannot be larger than the image size")
            return nil
        end
    end

    if target_ratio and target_ratio > 0 then
        local prev_ratio = w/h
        if prev_ratio ~= target_ratio then
            if (prev_ratio < target_ratio) then
                local old_h = h
                h = ceil(w * (1/target_ratio))
                offset_h = offset_h - ceil((old_h - h)/2)
            else
                local old_w = w
                w = ceil(h * target_ratio)
                offset_w = offset_w - ceil((old_w - w)/2)
            end
        end
    end

    local ret = cairo.ImageSurface(cairo.Format.ARGB32, w, h)
    local cr = cairo.Context(ret)
    cr:set_source_surface(surf, offset_w, offset_h)
    cr.operator = cairo.Operator.SOURCE
    cr:paint()

    return ret
end

return {
	color = color,
	pointer_on_focus = pointer_on_focus,
	textcursor_on_focus = textcursor_on_focus,
    crop_surface = crop_surface
}
