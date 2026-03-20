# List available tutorials

Lists the tutorial R Markdown files included with the package. Tutorials
are designed for classroom use in Korean political science methods
courses. Each tutorial is available in two formats:

1.  Plain Rmd for editing in RStudio
    ([`open_tutorial`](https://kyusik-yang.github.io/assemblykor/reference/open_tutorial.md))

2.  Interactive learnr format
    ([`run_tutorial`](https://kyusik-yang.github.io/assemblykor/reference/run_tutorial.md))

## Usage

``` r
list_tutorials()
```

## Value

A character vector of tutorial file names (invisibly).

## Examples

``` r
list_tutorials()
#> Available tutorials:
#> 
#>    01-tidyverse-basics.Rmd 
#>    02-data-visualization.Rmd 
#>    03-regression.Rmd 
#>    04-panel-data.Rmd 
#>    05-text-analysis.Rmd 
#>    06-network-analysis.Rmd 
#>    07-roll-call-analysis.Rmd 
#>    08-bill-success.Rmd 
#>    09-speech-patterns.Rmd 
#> 
#> Usage:
#>   open_tutorial(1)       # Copy Rmd to working directory
#>   run_tutorial(1)        # Launch interactive version in browser
```
