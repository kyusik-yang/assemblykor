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

A data frame with 663,582 rows and 4 variables, or `NULL` (invisibly) if
the download fails (e.g., no internet connection):

- date:

  Date of the committee meeting (links to `speeches$date`)

- speech_order:

  Speech turn within the meeting (links to `speeches$speech_order`);
  `date` + `speech_order` identifies one speech, except on 2024-06-25
  (see Details)

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
with `by = c("date", "speech_order")` to attach speaker metadata. Every
speech has at least one token. Two meetings were held on 2024-06-25, so
eight `speech_order` values of that date belong to two speeches each,
and their tokens are pooled under the shared key. Up to version 0.1.3
the file also held a second copy of the tokens of 48 speeches that
appeared twice in `speeches`.

The tokenization script is in the package source repository under
`data-raw/tokenize_speeches.py`.

## See also

[`speeches`](https://kyusik-yang.github.io/assemblykor/reference/speeches.md)

## Examples

``` r
# \donttest{
if (requireNamespace("arrow", quietly = TRUE)) {
  tokens <- get_speech_tokens(cache_dir = tempdir())

  if (!is.null(tokens)) {
    # Most frequent nouns
    nouns <- tokens[tokens$pos %in% c("NNG", "NNP"), ]
    head(sort(table(nouns$token), decreasing = TRUE), 20)
  }
}
#> Downloading speech tokens (~1.3 MB)...
#> Cached at: /tmp/Rtmpy0nnMp/speech_tokens_v2.parquet
#> 
#>   위원   방송   말씀   생각 위원장   부분   얘기     때   국민 후보자   문제 
#>   6408   5457   5443   4638   3649   3107   2983   2935   2873   2686   2641 
#> 위원회   관련   질의   사장   국회   자료   통신     말     법 
#>   2507   2386   2371   2315   2225   2221   2070   1991   1951 
# }
```
