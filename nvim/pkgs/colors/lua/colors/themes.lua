local colorschemes = {}

colorschemes.azul = function()
    local colors           = {}
    colors.background      = "#2b2f2f"
    colors.background_dark = "#333737"
    colors.inactive_tabs   = "#3b3f3f"
    colors.contrast        = "#434747"

    colors.foreground      = "#D8DAD3"
    colors.cursorline      = "#515757"
    colors.comment         = "#6C6F85"
    colors.cursor          = colors.foreground

    colors.color0          = "#939998"
    colors.color1          = "#cf7767"
    colors.color2          = "#7caf6e"
    colors.color3          = "#cac76b"
    colors.color4          = "#67a0d8"
    colors.color5          = "#b47fc5"
    colors.color6          = "#6cbaba"
    colors.color7          = "#222828"

    colors.color8          = "#9da3a2"
    colors.color9          = "#cf7d7d"
    colors.color10         = "#7bc578"
    colors.color11         = "#c8c67a"
    colors.color12         = "#71bae2"
    colors.color13         = "#ce99cf"
    colors.color14         = "#77bbc2"
    colors.color15         = "#3b4244"

    -- map extra colors used in light theme
    colors.color16         = colors.color8
    colors.color17         = colors.color9
    colors.color18         = colors.color10
    colors.color19         = colors.color11
    colors.color20         = colors.color12
    colors.color21         = colors.color13
    colors.color22         = colors.color14
    colors.color23         = colors.color15

    return colors
end

colorschemes.newpaper = function()
    local colors           = {}

    colors.background      = "#f1f3f2"
    colors.background_dark = "#e9ebea"
    colors.inactive_tabs   = "#e1e3e2"
    colors.contrast        = "#d9dbda"

    colors.foreground      = "#2b2b2b"
    colors.cursor          = colors.foreground

    colors.color0          = "#e4e4e4"
    colors.color1          = "#af0000"
    colors.color2          = "#008700"
    colors.color3          = "#af5f00"
    colors.color4          = "#27408b"
    colors.color5          = "#8700af"
    colors.color6          = "#005f87"
    colors.color7          = "#2b2b2b"

    colors.color8          = colors.foreground
    colors.color9          = "#e14133"
    colors.color10         = "#50A14F"
    colors.color11         = "#d75f00"
    colors.color12         = "#0072c1"
    colors.color13         = "#e563ba"
    colors.color14         = "#0087af"
    colors.color15         = "#585858"
    colors.comment         = colors.color15

    colors.color16         = colors.color8
    colors.color17         = colors.color9
    colors.color18         = colors.color10
    colors.color19         = colors.color11
    colors.color20         = colors.color12
    colors.color21         = colors.color13
    colors.color22         = colors.color14
    colors.color23         = colors.color15

    return colors
end

colorschemes.light = function()
    local colors           = {}
    colors.background      = "#E8EAE5"
    colors.background_dark = "#DCE0DC"
    colors.inactive_tabs   = "#D6D9D6"
    colors.contrast        = "#CCD0CC"
    colors.foreground      = "#2B2F2F"
    colors.cursorline      = "#515757"
    colors.comment         = "#6C6F85"
    colors.cursor          = colors.foreground

    -- dark
    colors.color0          = "#6b6767"
    colors.color1          = "#3f1a1a"
    colors.color2          = "#2c3f1e"
    colors.color3          = "#3a371b"
    colors.color4          = "#072548"
    colors.color5          = "#241f45"
    colors.color6          = "#0c3a3a"
    colors.color7          = "#333938"
    -- medium
    colors.color8          = colors.inactive_tabs
    colors.color9          = "#6f4d4d"
    colors.color10         = "#4b7548"
    colors.color11         = "#88862a"
    colors.color12         = "#316a92"
    colors.color13         = "#9e599f"
    colors.color14         = "#377b82"
    colors.color15         = "#414444"
    -- bright pastel (bg)
    colors.color16         = colors.background_dark
    colors.color17         = "#ECB5B5"
    colors.color18         = "#A2D5B5"
    colors.color19         = "#D5D5AB"
    colors.color20         = "#ABDBE5"
    colors.color21         = "#CBB4CB"
    colors.color22         = "#A8D8D0"
    colors.color23         = "#9292A2"
    return colors
end

colorschemes.mud = function()
    local colors           = colorschemes.light()
    colors.background      = "#D8DAC3"
    colors.background_dark = "#CCD0BA"
    colors.inactive_tabs   = "#C6C9B4"
    colors.contrast        = "#BCC0AA"
    colors.foreground      = "#2b2f2f"
    colors.cursorline      = "#515757"
    colors.comment         = "#6C6F85"

    colors.cursor          = colors.foreground
    colors.color8          = colors.inactive_tabs
    colors.color16         = colors.background_dark
    return colors
end

colorschemes.radium = function()
    local colors      = {
        background = "#101317",
        background_dark = "#23262a",
        inactive_tabs = "#2b2d34",
        contrast = "#33363a",

        comment = "#6b6d74",
        foreground = "#c5c5c6",

        color0 = "#cbcbcc",
        color1 = "#e87979",
        color2 = "#37d99e",
        color3 = "#e5d487",
        color4 = "#5fb0fc",
        color5 = "#c397d8",
        color6 = "#37d99e",
        color7 = "#2a2d31",

        color8 = "#c5c5c6",
        color9 = "#e87979",
        color10 = "#37d99e",
        color11 = "#f0a988",
        color12 = "#5fb0fc",
        color13 = "#c397d8",
        color14 = "#37d99e",
        color15 = "#3a3d41",
    }

    colors.cursor     = colors.foreground
    colors.cursorline = colors.color15

    colors.color16    = colors.color8
    colors.color17    = colors.color9
    colors.color18    = colors.color10
    colors.color19    = colors.color11
    colors.color20    = colors.color12
    colors.color21    = colors.color13
    colors.color22    = colors.color14
    colors.color23    = colors.color15

    return colors
end

colorschemes.readable_light = function()
    -- calced out colors with hsluv, NEW MATHEMATICALLY PRECISE
    -- BEST COLORSCHEME RIP BOZO SOLARIZED YOU WONT BE MISSED
    -- actually ass asthetically speaking, but very well readable

    local hsluv = require('hsluv')
    local colors = {
        -- every step down 2 L
        background = hsluv.hsluv_to_hex({ 231, 2, 93 }),
        background_dark = hsluv.hsluv_to_hex({ 231, 2, 90 }),
        inactive_tabs = hsluv.hsluv_to_hex({ 231, 2, 87 }),
        contrast = hsluv.hsluv_to_hex({ 231, 2, 84 }),

        -- 231, 7, 20
        foreground = hsluv.hsluv_to_hex({ 231, 7, 20 }),
        -- L -> 40
        cursorline = hsluv.hsluv_to_hex({ 231, 7, 40 }),
        -- L -> 55
        comment = hsluv.hsluv_to_hex({ 231, 7, 55 }),

        -- white and black are just variations of fg and bg
        color0 = hsluv.hsluv_to_hex({ 231, 7, 30 }),
        color8 = hsluv.hsluv_to_hex({ 231, 7, 50 }),
        color16 = hsluv.hsluv_to_hex({ 231, 7, 70 }),

        color7 = hsluv.hsluv_to_hex({ 231, 7, 10 }),
        color15 = hsluv.hsluv_to_hex({ 231, 7, 30 }),
        color23 = hsluv.hsluv_to_hex({ 231, 7, 50 }),
    }

    -- gen colors
    -- H:
    --  red: 12 (#ff0000)
    --  yellow: 86 (#ffff00)
    --  green: 127 (#00ff00)
    --  cyan: 192 (#00ffff)
    --  blue: 266 (#0000ff)
    --  purple: 307 (#ff00ff)
    for id, hue in pairs({
        [1] = 12,
        [2] = 127,
        [3] = 86,
        [4] = 240,
        [5] = 307,
        [6] = 192
    }) do
        for _, i in pairs({ 0, 1, 2 }) do
            colors["color" .. tostring(id + 8 * i)] = hsluv.hsluv_to_hex({ hue, 60 - (10 * i), 20 + (32.5 * i) })
        end
    end

    --     color1 = "#ac3132",
    --     color9 = "#e7696a",
    --     color17 = "#f0b9b9",
    --
    --     color2 = "#326a30",
    --     color10 = "#50a24d",
    --     color18 = "#70de6c",
    --
    --     color3 = "#7f5531",
    --     color11 = "#c0834e",
    --     color19 = "#f1bc97",
    --
    --     color4 = "#4f4ec7",
    --     color12 = "#8888de",
    --     color20 = "#c3c3ef",
    --
    --     color5 = "#943a8f",
    --     color13 = "#de5cd7",
    --     color21 = "#efb3ea",
    --
    --     color6 = "#386188",
    --     color14 = "#5995ce",
    --     color22 = "#abc9ef",
    -- }

    colors.cursor = colors.foreground

    return colors
end

return colorschemes
