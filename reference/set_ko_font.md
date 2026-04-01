# Set Korean font for ggplot2

Detects a Korean-compatible font on the current system and applies it to
all ggplot2 plots via
[`theme_set()`](https://ggplot2.tidyverse.org/reference/get_theme.html).
Call this once at the top of your script to avoid broken Korean text in
plot titles and labels.

## Usage

``` r
set_ko_font(font = NULL)
```

## Arguments

- font:

  Optional font family name to use directly. If `NULL` (default),
  auto-detects from common Korean fonts.

## Value

The font family name used (invisibly).

## Examples

``` r
if (interactive()) {
  library(ggplot2)
  set_ko_font()

  # Now Korean text renders correctly
  ggplot(data.frame(x = 1), aes(x, x)) +
    geom_point() +
    labs(title = "Korean Title Test")
}
```
