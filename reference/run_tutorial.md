# Run an interactive tutorial

Launches a learnr interactive tutorial in the browser. Students can type
and run code directly in the browser with hints and solutions. Requires
the learnr package.

## Usage

``` r
run_tutorial(name)
```

## Arguments

- name:

  Tutorial name or number (1-9). Use
  [`list_tutorials`](https://kyusik-yang.github.io/assemblykor/reference/list_tutorials.md)
  to see available tutorials.

## Value

No return value, called for the side effect of launching a learnr
tutorial in the browser.

## See also

[`open_tutorial`](https://kyusik-yang.github.io/assemblykor/reference/open_tutorial.md)
for the plain Rmd version.

## Examples

``` r
if (interactive()) {
  run_tutorial(1)
}
```
