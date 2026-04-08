library(hexSticker)
library(showtext)

font_add_google("Fira Mono", "firamono")
showtext_auto()

s <- sticker(
  "building_only.png",
  package = "assemblykor",
  p_size = 15,
  p_y = 0.55,
  p_color = "#FFFFFF",
  p_family = "firamono",
  p_fontface = "bold",
  s_x = 1,
  s_y = 1.15,
  s_width = 0.82,
  s_height = 0.52,
  h_fill = "#14213D",
  h_color = "#4A90D9",
  h_size = 1.5,
  white_around_sticker = FALSE,
  filename = "logo.png",
  dpi = 300
)

cat("Done\n")
