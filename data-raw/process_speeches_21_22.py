"""
process_speeches_21_22.py
Extracts speech data from 21st-22nd assembly xlsx files where each
meeting's speeches are stored in separate sheets ({회의번호}_발언내용).

Appends to the existing speeches_all_committees.csv.

Output: data-raw/speeches_all_committees.csv (appended)
"""

import os
import re
import csv
import pandas as pd

SRC = "/Volumes/kyusik-ssd/kyusik-research/projects/who-owns-nk-policy/data"
OUT = os.path.join(os.path.dirname(__file__), "speeches_all_committees.csv")


def parse_date(raw):
    """Parse Korean-style date: 2020년6월16일(화) -> 2020-06-16"""
    if not raw or not isinstance(raw, str):
        return ""
    raw = raw.strip()
    m = re.match(r"(\d{4})\ub144\s*(\d{1,2})\uc6d4\s*(\d{1,2})\uc77c", raw)
    if m:
        return f"{m.group(1)}-{int(m.group(2)):02d}-{int(m.group(3)):02d}"
    m = re.match(r"(\d{4}-\d{2}-\d{2})", raw)
    if m:
        return m.group(1)
    return ""


def process_term(term, writer):
    fp = os.path.join(SRC,
        f"제{term}대 국회 상임위원회 회의록 데이터셋",
        f"제{term}대 국회 상임위원회 회의록 데이터셋.xlsx")

    if not os.path.exists(fp):
        print(f"  File not found: {fp}")
        return 0

    xf = pd.ExcelFile(fp)
    speech_sheets = [s for s in xf.sheet_names if "발언내용" in s]
    print(f"  {len(speech_sheets)} speech sheets")

    total = 0
    for i, sn in enumerate(speech_sheets):
        if (i + 1) % 100 == 0:
            print(f"    Progress: {i+1}/{len(speech_sheets)} ({total:,} speeches)")

        try:
            df = pd.read_excel(xf, sheet_name=sn, header=2)
        except Exception as e:
            continue

        if df.empty:
            continue

        # Columns for 21-22대: 회의번호(0), ..., 위원회(4), ..., 회의일자(8),
        #   안건1(9), 안건2(10), 발언자(11), 의원ID(12), 발언순번(13), 발언내용1-7(14-20)
        cols = list(df.columns)

        # Find key columns by name
        committee_col = "위원회" if "위원회" in cols else cols[4]
        date_col = "회의일자" if "회의일자" in cols else cols[8]
        speaker_col = "발언자" if "발언자" in cols else cols[11]
        member_col = "의원ID" if "의원ID" in cols else cols[12]
        order_col = "발언순번" if "발언순번" in cols else cols[13]

        # Speech content columns
        speech_cols = [c for c in cols if str(c).startswith("발언내용")]

        batch = []
        for _, row in df.iterrows():
            parts = []
            for sc in speech_cols:
                val = row.get(sc)
                if pd.notna(val) and str(val).strip():
                    parts.append(str(val).strip())
            speech = " ".join(parts)
            if len(speech) < 10:
                continue

            committee = str(row.get(committee_col, "")).strip()
            date_raw = str(row.get(date_col, "")).strip()
            speaker = str(row.get(speaker_col, "")).strip()
            member_num = str(row.get(member_col, "")).strip()
            order = str(row.get(order_col, "")).strip()
            date_clean = parse_date(date_raw)

            if member_num == "nan":
                member_num = ""

            batch.append([str(term), date_clean, committee, speaker,
                         member_num, order, speech])

        writer.writerows(batch)
        total += len(batch)

    xf.close()
    return total


def main():
    # Append to existing CSV
    with open(OUT, "a", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)

        for term in [21, 22]:
            print(f"\n제{term}대:")
            count = process_term(term, writer)
            print(f"  Total: {count:,} speeches")

    size_mb = os.path.getsize(OUT) / (1024 * 1024)
    print(f"\nUpdated file size: {size_mb:.1f} MB")


if __name__ == "__main__":
    main()
