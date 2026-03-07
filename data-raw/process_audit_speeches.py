"""
process_audit_speeches.py
Extracts parliamentary audit (국정감사) speech data from xlsx files
and appends to speeches_all_committees.csv.

16-20대: per-committee xlsx files (same structure as 상임위원회)
21-22대: single xlsx with per-meeting sheets (like 상임위원회 21-22대)

Run from the assemblykor package root:
    python3 data-raw/process_audit_speeches.py
"""

import os
import re
import glob
import csv
import openpyxl
import pandas as pd

SRC = "/Volumes/kyusik-ssd/kyusik-research/data-national-assembly-meetings"
OUT = os.path.join(os.path.dirname(__file__), "speeches_all_committees.csv")

# Column indices for 16-20대 (same as standing committee files)
COL_ASSEMBLY = 2
COL_COMMITTEE = 4
COL_DATE = 8
COL_SPEAKER = 10
COL_MEMBER_NUM = 11
COL_ORDER = 12
COL_SPEECH_START = 13
COL_SPEECH_END = 20


def parse_date(raw):
    if not raw or not isinstance(raw, str):
        return ""
    raw = raw.strip()
    m = re.match(r"(\d{4})\u5e74(\d{1,2})\u6708(\d{1,2})\u65e5", raw)
    if m:
        return f"{m.group(1)}-{int(m.group(2)):02d}-{int(m.group(3)):02d}"
    m = re.match(r"(\d{4})\ub144\s*(\d{1,2})\uc6d4\s*(\d{1,2})\uc77c", raw)
    if m:
        return f"{m.group(1)}-{int(m.group(2)):02d}-{int(m.group(3)):02d}"
    m = re.match(r"(\d{4}-\d{2}-\d{2})", raw)
    if m:
        return m.group(1)
    return ""


def process_xlsx_16_20(filepath, writer):
    """Process per-committee xlsx files (16-20대)."""
    try:
        wb = openpyxl.load_workbook(filepath, read_only=True)
    except Exception as e:
        print(f"  ERROR: {e}")
        return 0

    ws = wb.active
    skipped_header = False
    batch = []

    for row in ws.iter_rows(values_only=True):
        if not skipped_header:
            skipped_header = True
            continue

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
        # Tag as audit hearing
        committee = committee + "(국정감사)" if committee else "(국정감사)"
        date_raw = str(row[COL_DATE]).strip() if row[COL_DATE] else ""
        speaker = str(row[COL_SPEAKER]).strip() if row[COL_SPEAKER] else ""
        member_num = str(row[COL_MEMBER_NUM]).strip() if row[COL_MEMBER_NUM] else ""
        order = str(row[COL_ORDER]).strip() if row[COL_ORDER] else ""

        batch.append([assembly, parse_date(date_raw), committee, speaker,
                     member_num, order, speech])

    writer.writerows(batch)
    wb.close()
    return len(batch)


def process_xlsx_21_22(filepath, term, writer):
    """Process per-sheet xlsx files (21-22대)."""
    xf = pd.ExcelFile(filepath)
    speech_sheets = [s for s in xf.sheet_names if "발언내용" in s]
    print(f"  {len(speech_sheets)} speech sheets")

    total = 0
    for i, sn in enumerate(speech_sheets):
        if (i + 1) % 100 == 0:
            print(f"    Progress: {i+1}/{len(speech_sheets)} ({total:,} speeches)")

        try:
            df = pd.read_excel(xf, sheet_name=sn, header=2)
        except Exception:
            continue

        if df.empty:
            continue

        cols = list(df.columns)
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

            committee = str(row.get("위원회", "")).strip()
            committee = committee + "(국정감사)" if committee else "(국정감사)"
            date_raw = str(row.get("회의일자", "")).strip()
            speaker = str(row.get("발언자", "")).strip()
            member_num = str(row.get("의원ID", "")).strip()
            order = str(row.get("발언순번", "")).strip()
            if member_num == "nan":
                member_num = ""

            batch.append([str(term), parse_date(date_raw), committee, speaker,
                         member_num, order, speech])

        writer.writerows(batch)
        total += len(batch)

    xf.close()
    return total


def main():
    grand_total = 0

    with open(OUT, "a", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)

        # 16-20대: per-committee xlsx in directories
        for term in range(16, 21):
            term_dir = os.path.join(SRC, f"제{term}대 국회 국정감사 회의록 데이터셋")
            if not os.path.isdir(term_dir):
                print(f"제{term}대 국정감사: directory not found, skipping")
                continue

            files = sorted(glob.glob(os.path.join(term_dir, "*.xlsx")))
            print(f"\n제{term}대 국정감사: {len(files)} files")

            term_total = 0
            for fi, fp in enumerate(files):
                fname = os.path.basename(fp)
                m = re.search(r"국정감사 (.+?) 회의록", fname)
                cname = m.group(1) if m else fname
                count = process_xlsx_16_20(fp, writer)
                term_total += count
                print(f"  [{fi+1}/{len(files)}] {cname}: {count:,}")

            grand_total += term_total
            print(f"  Total: {term_total:,}")

        # 21-22대: single xlsx with per-meeting sheets
        for term in [21, 22]:
            fp = os.path.join(SRC, f"제{term}대 국회 국정감사 회의록 데이터셋.xlsx")
            if not os.path.exists(fp):
                print(f"\n제{term}대 국정감사: file not found, skipping")
                continue

            print(f"\n제{term}대 국정감사:")
            count = process_xlsx_21_22(fp, term, writer)
            grand_total += count
            print(f"  Total: {count:,}")

    print(f"\n국정감사 total: {grand_total:,} speeches added")
    size_mb = os.path.getsize(OUT) / (1024 * 1024)
    print(f"Updated file size: {size_mb:.1f} MB")


if __name__ == "__main__":
    main()
