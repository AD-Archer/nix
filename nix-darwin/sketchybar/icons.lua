local settings = require("settings")

local icons = {
  sf_symbols = {
    volume = {
      _100 = "􀊩",
      _66 = "􀊧",
      _33 = "􀊥",
      _10 = "􀊡",
      _0 = "􀊣",
    },
    battery = {
      _100 = "􀛨",
      _75 = "􀺸",
      _50 = "􀺶",
      _25 = "􀛩",
      _0 = "􀛪",
      charging = "􀢋",
    },
    media = {
      play_pause = "􀊈",
    },
  },

  nerdfont = {
    volume = {
      _100 = "",
      _66 = "",
      _33 = "",
      _10 = "",
      _0 = "",
    },
    battery = {
      _100 = "",
      _75 = "",
      _50 = "",
      _25 = "",
      _0 = "",
      charging = "",
    },
    media = {
      play_pause = "",
    },
  },
}

if settings.icons == "NerdFont" then
  return icons.nerdfont
end

return icons.sf_symbols
