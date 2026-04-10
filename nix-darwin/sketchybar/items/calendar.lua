local settings = require("settings")

local cal = sbar.add("item", "calendar", {
  position = "right",
  update_freq = 30,
  padding_left = 1,
  padding_right = 1,
  icon = {
    font = {
      family = settings.font.text,
      style = settings.font.style_map["Regular"],
      size = settings.font.size,
    },
    padding_left = 8,
  },
  label = {
    align = "right",
    font = {
      family = settings.font.text,
      style = settings.font.style_map["Regular"],
      size = settings.font.size,
    },
    padding_right = 10,
  },
})

local function update_calendar()
  cal:set({
    icon = os.date("%a %d %b"),
    label = os.date("%H:%M"),
  })
end

cal:subscribe({ "forced", "routine", "system_woke" }, update_calendar)

cal:subscribe("mouse.clicked", function()
  sbar.exec("/usr/bin/open -a Calendar")
end)

update_calendar()
