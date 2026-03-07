"""
process_all_speeches.py
Reads all standing-committee minutes xlsx files (16th-22nd assemblies)
from the who-owns-nk-policy project and produces a single CSV for
assemblykor's speeches dataset.

Run from the assemblykor package root:
    python3 data-raw/process_all_speeches.py

Output: data-raw/speeches_all_committees.csv
"""

import os
import re
import glob
import openpyxl
import csv
import sys
from datetime import datetime

SRC = "/Volumes/kyusik-ssd/kyusik-research/projects/who-owns-nk-policy/data"
OUT = os.path.join(os.path.dirname(__file__), "speeches_all_committees.csv")

# Column indices in the xlsx files (0-based)
COL_MEETING_ID = 0   # 회의번호
COL_ASSEMBLY = 2     # 대수
COL_COMMITTEE = 4    # 위원회
COL_DATE = 8         # 회의일자
COL_AGENDA = 9       # 안건
COL_SPEAKER = 10     # 발언자
COL_MEMBER_NUM = 11  # 의원ID (numeric, not MONA_CD)
COL_ORDER = 12       # 발언순번
COL_SPEECH_START = 13  # 발언내용1 (through 발언내용7, cols 13-19)
COL_SPEECH_END = 20


def parse_date(raw):
    """Parse mixed-format dates from committee minutes."""
    if not raw or not isinstance(raw, str):
        return ""
    raw = raw.strip()
    # Japanese-style: 2004年7月6日(火)
    m = re.match(r"(\d{4})\u5e74(\d{1,2})\u6708(\d{1,2})\u65e5", raw)
    if m:
        return f"{m.group(1)}-{int(m.group(2)):02d}-{int(m.group(3)):02d}"
    # Korean-style: 2020년12월03일(목)
    m = re.match(r"(\d{4})\ub144\s*(\d{1,2})\uc6d4\s*(\d{1,2})\uc77c", raw)
    if m:
        return f"{m.group(1)}-{int(m.group(2)):02d}-{int(m.group(3)):02d}"
    # Already ISO
    m = re.match(r"(\d{4}-\d{2}-\d{2})", raw)
    if m:
        return m.group(1)
    return ""


def process_xlsx(filepath, writer, counter):
    """Read a single xlsx file and write rows to CSV."""
    try:
        wb = openpyxl.load_workbook(filepath, read_only=True)
    except Exception as e:
        print(f"  ERROR opening {os.path.basename(filepath)}: {e}")
        return counter

    ws = wb.active
    skipped_header = False
    batch = []

    for row in ws.iter_rows(values_only=True):
        if not skipped_header:
            skipped_header = True
            continue

        # Concatenate speech columns (발언내용1-7)
        parts = []
        for i in range(COL_SPEECH_START, min(COL_SPEECH_END, len(row))):
            val = row[i] if i < len(row) else None
            if val and isinstance(val, str) and val.strip():
                parts.append(val.strip())
        speech = " ".join(parts)

        if not speech or len(speech) < 10:
            continue

        assembly = str(row[COL_ASSEMBLY]).strip() if row[COL_ASSEMBLY] else ""
        committee = str(row[COL_COMMITTEE]).strip() if row[COL_COMMITTEE] else ""
        date_raw = str(row[COL_DATE]).strip() if row[COL_DATE] else ""
        speaker = str(row[COL_SPEAKER]).strip() if row[COL_SPEAKER] else ""
        member_num = str(row[COL_MEMBER_NUM]).strip() if row[COL_MEMBER_NUM] else ""
        order = str(row[COL_ORDER]).strip() if row[COL_ORDER] else ""

        date_clean = parse_date(date_raw)

        batch.append([assembly, date_clean, committee, speaker, member_num, order, speech])
        counter += 1

    writer.writerows(batch)
    wb.close()
    return counter


def main():
    total = 0

    with open(OUT, "w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        writer.writerow(["assembly", "date", "committee", "speaker",
                         "member_num_id", "speech_order", "speech"])

        # Process each assembly
        for term in range(16, 23):
            term_dir = os.path.join(SRC, f"제{term}대 국회 상임위원회 회의록 데이터셋")
            if not os.path.isdir(term_dir):
                print(f"제{term}대: directory not found, skipping")
                continue

            files = sorted(glob.glob(os.path.join(term_dir, "*.xlsx")))
            print(f"\n제{term}대: {len(files)} file(s)")

            for fi, fp in enumerate(files):
                fname = os.path.basename(fp)
                # Extract committee name from filename
                m = re.search(r"상임위원회 (.+?) 회의록", fname)
                cname = m.group(1) if m else fname
                before = total
                total = process_xlsx(fp, writer, total)
                added = total - before
                print(f"  [{fi+1}/{len(files)}] {cname}: {added:,} speeches")

    print(f"\nTotal speeches: {total:,}")
    print(f"Saved to: {OUT}")
    size_mb = os.path.getsize(OUT) / (1024 * 1024)
    print(f"File size: {size_mb:.1f} MB")


if __name__ == "__main__":
    main()
