# Tokenize the `speeches` dataset with kiwipiepy (Kiwi morphological
# analyzer) and save content morphemes as a long-format parquet file.
#
# Output: speech_tokens.parquet, one row per morpheme occurrence, keyed
# by (date, speech_order) which uniquely identifies a speech within the
# `speeches` dataset. Only content morphemes are kept:
#   NNG (common noun), NNP (proper noun), VV (verb), VA (adjective),
#   MAG (general adverb), SL (foreign word, e.g. "AI")
# Verbs/adjectives are stored as their lemma (dictionary form with -da).
#
# Usage:
#   1. In R: export speeches to speeches_for_tokenize.parquet
#      (columns: date, speech_order, speaker_name, role, speech)
#   2. python3 tokenize_speeches.py <input.parquet> <output.parquet>
#
# Requires: pip install kiwipiepy pyarrow

import sys

import pyarrow as pa
import pyarrow.parquet as pq
from kiwipiepy import Kiwi

KEEP_TAGS = {"NNG", "NNP", "VV", "VA", "MAG", "SL"}
PREDICATE_TAGS = {"VV", "VA"}

def main(in_path, out_path):
    table = pq.read_table(in_path)
    df = table.to_pydict()
    n = len(df["speech"])

    kiwi = Kiwi()

    dates, orders, tokens, tags = [], [], [], []
    for i in range(n):
        text = df["speech"][i]
        if not text:
            continue
        for tok in kiwi.tokenize(text):
            if tok.tag not in KEEP_TAGS:
                continue
            form = tok.form
            if tok.tag in PREDICATE_TAGS:
                form = form + "다"  # lemma: append "-da"
            dates.append(df["date"][i])
            orders.append(df["speech_order"][i])
            tokens.append(form)
            tags.append(tok.tag)
        if (i + 1) % 1000 == 0:
            print(f"  {i + 1}/{n} speeches tokenized", flush=True)

    out = pa.table({
        "date": pa.array(dates, type=table.schema.field("date").type),
        "speech_order": pa.array(orders),
        "token": pa.array(tokens),
        "pos": pa.array(tags),
    })
    # gzip, not zstd: CRAN's default arrow build lacks the zstd codec
    pq.write_table(out, out_path, compression="gzip")
    print(f"Wrote {out.num_rows:,} tokens from {n:,} speeches to {out_path}")

if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2])
