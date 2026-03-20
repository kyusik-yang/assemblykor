# Open a tutorial file

Copies a tutorial R Markdown file to the specified directory (default:
current working directory) so students can edit and run it in RStudio.

## Usage

``` r
open_tutorial(name, dest_dir = getwd())
```

## Arguments

- name:

  Tutorial name (with or without .Rmd extension), or a number
  corresponding to the tutorial order (1-9).

- dest_dir:

  Directory to copy the file to. Defaults to the current working
  directory.

## Value

The path to the copied file (invisibly).

## See also

[`run_tutorial`](https://kyusik-yang.github.io/assemblykor/reference/run_tutorial.md)
for the interactive browser version.

## Examples

``` r
if (FALSE) { # \dontrun{
# Copy by name
open_tutorial("01-tidyverse-basics")

# Copy by number
open_tutorial(1)
} # }
```
