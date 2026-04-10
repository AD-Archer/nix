local colors = require("colors")
local settings = require("settings")

local front_app = sbar.add("item", "front_app", {
  position = "center",
  icon = {
    drawing = false,
  },
  label = {
    font = {
      family = settings.font.text,
      style = settings.font.style_map["Black"],
      size = 12.0,
    },
    max_chars = 50,
  },
  background = {
    color = colors.bg1,
  },
})

front_app:subscribe("front_app_switched", function(env)
  front_app:set({
    label = {
      string = env.INFO or "Desktop",
    },
  })
end)
