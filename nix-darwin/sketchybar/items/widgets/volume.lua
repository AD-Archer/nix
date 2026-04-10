local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

local popup_width = 150

local volume_percent = sbar.add("item", "widgets.volume.percent", {
  position = "right",
  icon = { drawing = false },
  label = {
    string = "??%",
    padding_left = -1,
    padding_right = settings.padding.icon_label_item.label.padding_right,
    font = {
      family = settings.font.numbers,
      style = settings.font.style_map["Bold"],
      size = settings.label_size,
    },
    align = "right",
  },
  background = { drawing = false },
})

local volume_icon = sbar.add("item", "widgets.volume.icon", {
  position = "right",
  icon = {
    color = colors.white,
    font = {
      family = settings.font_icon.text,
      style = settings.font_icon.style_map["Bold"],
      size = settings.icon_size,
    },
    padding_left = settings.padding.icon_label_item.icon.padding_left - 4,
    padding_right = settings.padding.icon_item.icon.padding_right - 10,
    string = icons.volume._100,
  },
  background = { drawing = false },
  label = { drawing = false },
})

local volume_bracket = sbar.add("bracket", "widgets.volume.bracket", {
  volume_icon.name,
  volume_percent.name,
}, {
  background = { color = colors.bg1 },
  popup = { align = "center" },
})

local volume_slider = sbar.add("slider", "widgets.volume.slider", popup_width, {
  position = "popup." .. volume_bracket.name,
  slider = {
    highlight_color = colors.accent,
    background = {
      color = colors.bg2,
      height = 6,
    },
    knob = {
      string = "􀀁",
      drawing = true,
    },
  },
  background = {
    color = colors.bg1,
    height = 2,
    padding_left = 12,
    padding_right = 0,
  },
  click_script = '/usr/bin/osascript -e "set volume output volume $PERCENTAGE"',
})

local function render_volume(volume)
  local icon = icons.volume._0
  if volume > 60 then
    icon = icons.volume._100
  elseif volume > 30 then
    icon = icons.volume._66
  elseif volume > 10 then
    icon = icons.volume._33
  elseif volume > 0 then
    icon = icons.volume._10
  end

  local lead = volume > 0 and volume < 10 and "0" or ""
  volume_icon:set({ icon = { string = icon } })
  volume_percent:set({ label = { string = lead .. volume .. "%" } })
  volume_slider:set({ slider = { percentage = volume } })
end

local function refresh_volume(env)
  if env and env.INFO then
    render_volume(tonumber(env.INFO))
    return
  end

  sbar.exec('/usr/bin/osascript -e \'output volume of (get volume settings)\'', function(result)
    local volume = tonumber(result) or 0
    render_volume(volume)
  end)
end

local function toggle_slider(env)
  if env.BUTTON == "right" then
    sbar.exec("/usr/bin/open /System/Library/PreferencePanes/Sound.prefPane")
    return
  end

  local should_draw = volume_bracket:query().popup.drawing == "off"
  volume_bracket:set({
    popup = { drawing = should_draw },
  })
end

local function collapse_slider()
  if volume_bracket:query().popup.drawing == "on" then
    volume_bracket:set({ popup = { drawing = false } })
  end
end

local function scroll_volume(env)
  local delta = env.INFO.delta
  if env.INFO.modifier ~= "ctrl" then
    delta = delta * 10.0
  end

  sbar.exec('/usr/bin/osascript -e "set volume output volume (output volume of (get volume settings) + ' .. delta .. ')"')
end

volume_percent:subscribe({ "volume_change", "system_woke" }, refresh_volume)
volume_icon:subscribe({ "volume_change", "system_woke" }, refresh_volume)

volume_icon:subscribe("mouse.clicked", toggle_slider)
volume_percent:subscribe("mouse.clicked", toggle_slider)
volume_percent:subscribe("mouse.exited.global", collapse_slider)
volume_icon:subscribe("mouse.scrolled", scroll_volume)
volume_percent:subscribe("mouse.scrolled", scroll_volume)

refresh_volume()
