local colors = require("colors")

sbar.bar({
  height = 30,
  y_offset = 2,
  color = colors.bar.bg,
  border_color = colors.bar.border,
  shadow = true,
  sticky = true,
  blur_radius = 20,
  padding_left = 10,
  padding_right = 10,
  topmost = "window",
})
