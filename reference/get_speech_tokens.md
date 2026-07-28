# Download morpheme tokens for committee speeches

Downloads a pre-tokenized version of the
[`speeches`](https://kyusik-yang.github.io/assemblykor/reference/speeches.md)
dataset, produced with the Kiwi morphological analyzer (via
`kiwipiepy`). Korean is an agglutinative language, so whitespace
tokenization mixes particles and verb endings into the tokens;
morphological analysis separates them and lemmatizes verbs and
adjectives. This dataset lets students work with proper Korean tokens
without installing a morphological analyzer. The file is approximately
1.3 MB and is cached locally after the first download. Requires the
arrow package.

## Usage

``` r
get_speech_tokens(cache_dir = NULL, force_download = FALSE)
```

## Arguments

- cache_dir:

  Directory to cache downloaded files. Defaults to
  `tools::R_user_dir("assemblykor", "cache")`.

- force_download:

  Logical. If `TRUE`, re-download even if cached.

## Value

A data frame with 665,055 rows and 4 variables, or `NULL` (invisibly) if
the download fails (e.g., no internet connection):

- date:

  Date of the committee meeting (links to `speeches$date`)

- speech_order:

  Speech turn within the meeting (links to `speeches$speech_order`);
  `date` + `speech_order` identifies one speech

- token:

  Morpheme, in dictionary form. Verbs and adjectives are lemmatized
  (e.g., the stem plus `-da`)

- pos:

  Part-of-speech tag from the Sejong tagset: "NNG" (common noun), "NNP"
  (proper noun), "VV" (verb), "VA" (adjective), "MAG" (adverb), or "SL"
  (foreign word, e.g., "AI")

## Details

Only content morphemes are included; particles (josa), verb endings
(eomi), and punctuation are removed. Function words carry little topical
meaning, so this is the usual starting point for keyword and topic
analysis. For noun-based analysis, filter to `pos %in% c("NNG", "NNP")`.

Join back to
[`speeches`](https://kyusik-yang.github.io/assemblykor/reference/speeches.md)
with `by = c("date", "speech_order")` to attach speaker metadata. A
small number of speeches (56 of 15,843) yield no content morphemes and
therefore do not appear.

The tokenization script is in the package source repository under
`data-raw/tokenize_speeches.py`.

## See also

[`speeches`](https://kyusik-yang.github.io/assemblykor/reference/speeches.md)

## Examples

``` r
# \donttest{
if (requireNamespace("arrow", quietly = TRUE)) {
  tokens <- get_speech_tokens(cache_dir = tempdir())

  # Most frequent nouns
  nouns <- tokens[tokens$pos %in% c("NNG", "NNP"), ]
  head(sort(table(nouns$token), decreasing = TRUE), 20)
}
#> Downloading speech tokens (~1.3 MB)...
#> Cached at: /tmp/RtmpEAD6MI/speech_tokens.parquet
#> 
#>   위원   방송   말씀   생각 위원장   부분   얘기     때   국민 후보자   문제 
#>   6412   5476   5451   4659   3657   3115   2989   2939   2878   2686   2659 
#> 위원회   관련   질의   사장   국회   자료   통신     말     법 
#>   2511   2390   2378   2316   2228   2225   2074   1991   1953 
# }
```
