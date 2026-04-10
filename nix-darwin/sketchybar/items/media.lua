local icons = require("icons")
local colors = require("colors")
local settings = require("settings")

local whitelist = {
  ["Google Chrome"] = true,
  ["Firefox"] = true,
  ["Music"] = true,
  ["Plexamp"] = true,
  ["Safari"] = true,
  ["Spotify"] = true,
}

local function media_color(app_name)
  if app_name == "Music" then
    return colors.red_bright
  elseif app_name == "Plexamp" then
    return colors.yellow
  elseif app_name == "Spotify" then
    return colors.spotify_green
  elseif app_name == "Safari" or app_name == "Firefox" or app_name == "Google Chrome" then
    return colors.blue_bright
  end

  return colors.default
end

local now_playing = sbar.add("item", "media", {
  position = "right",
  drawing = false,
  background = {
    color = colors.spotify_green,
  },
  icon = {
    string = icons.media.play_pause,
    padding_left = settings.padding.icon_label_item.icon.padding_left,
    padding_right = settings.padding.icon_label_item.icon.padding_right,
  },
  label = {
    highlight = false,
    max_chars = 30,
    padding_left = settings.padding.icon_label_item.label.padding_left,
    padding_right = settings.padding.icon_label_item.label.padding_right,
  },
})

local was_playing = false

now_playing:subscribe("media_change", function(env)
  if not whitelist[env.INFO.app] then
    return
  end

  local is_playing = env.INFO.state == "playing"
  local app_color = media_color(env.INFO.app)
  local started_playing = not was_playing and is_playing

  now_playing:set({
    background = { color = app_color },
    drawing = is_playing,
    label = { string = env.INFO.title .. " - " .. env.INFO.artist },
  })

  if started_playing then
    now_playing:animate("sin", 10.0, function()
      now_playing:set({
        background = { color = app_color .. "aa" },
      })
    end, function()
      now_playing:set({
        background = { color = app_color },
      })
    end)
  end

  was_playing = is_playing
end)

now_playing:subscribe("system_woke", function()
  sbar.trigger("media_change")
end)
