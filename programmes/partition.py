#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import argparse
import math
from collections import Counter
from pathlib import Path


def read_tokens(path: Path) -> Counter:
    c = Counter()
    with path.open("r", encoding="utf-8", errors="ignore") as f:
        for line in f:
            tok = line.strip()
            if tok:
                c[tok] += 1
    return c


def llr_2x2(k11, k12, k21, k22) -> float:
    """
    Log-likelihood ratio (G^2) for 2x2 table:
      [k11 k12]
      [k21 k22]
    Returns >= 0.
    """
    def xlogx(x):
        return 0.0 if x <= 0 else x * math.log(x)

    row1 = k11 + k12
    row2 = k21 + k22
    col1 = k11 + k21
    col2 = k12 + k22
    n = row1 + row2
    if n == 0:
        return 0.0

    # Expected counts
    e11 = row1 * col1 / n if n else 0
    e12 = row1 * col2 / n if n else 0
    e21 = row2 * col1 / n if n else 0
    e22 = row2 * col2 / n if n else 0

    # G^2 = 2 * sum( k * log(k/e) )
    g2 = 0.0
    for k, e in [(k11, e11), (k12, e12), (k21, e21), (k22, e22)]:
        if k > 0 and e > 0:
            g2 += k * math.log(k / e)
    return 2.0 * g2


def main():
    p = argparse.ArgumentParser(
        description="Partitionner un corpus tokenisé (1 token/ligne) et calculer un score de spécificité (LLR) par partition."
    )
    p.add_argument(
        "-i", "--inputs",
        nargs="+",
        action="append",
        required=True,
        help="Une partition = une liste de fichiers tokenisés. Répéter -i pour plusieurs partitions."
    )
    p.add_argument(
        "--n-firsts",
        type=int,
        default=200,
        help="Nombre de tokens à afficher par partition (défaut: 200)."
    )
    args = p.parse_args()

    # Load partitions
    part_counters = []
    part_totals = []
    part_files = []

    for group in args.inputs:
        files = [Path(x) for x in group]
        part_files.append(files)
        c = Counter()
        for fp in files:
            if not fp.exists():
                raise SystemExit(f"Fichier introuvable: {fp}")
            c += read_tokens(fp)
        part_counters.append(c)
        part_totals.append(sum(c.values()))

    # Global counts
    global_c = Counter()
    for c in part_counters:
        global_c += c
    global_total = sum(global_c.values())

    # Output TSV
    # Columns: partition_id, token, count_in_partition, count_in_rest, llr, direction
    # direction = "+" if over-represented in partition, "-" otherwise
    print("partition\ttoken\tcount_part\tcount_rest\tllr\tdirection")

    for i, (c_part, n_part) in enumerate(zip(part_counters, part_totals), start=1):
        n_rest = global_total - n_part
        scored = []
        for tok, k_part in c_part.items():
            k_global = global_c[tok]
            k_rest = k_global - k_part
            # 2x2:
            # tok vs not tok, in partition vs rest
            k11 = k_part
            k12 = n_part - k_part
            k21 = k_rest
            k22 = n_rest - k_rest
            score = llr_2x2(k11, k12, k21, k22)

            # Over/under representation
            # compare relative frequencies
            f_part = (k_part / n_part) if n_part else 0.0
            f_rest = (k_rest / n_rest) if n_rest else 0.0
            direction = "+" if f_part >= f_rest else "-"

            scored.append((score, tok, k_part, k_rest, direction))

        scored.sort(reverse=True, key=lambda x: x[0])
        for score, tok, k_part, k_rest, direction in scored[: args.n_firsts]:
            print(f"{i}\t{tok}\t{k_part}\t{k_rest}\t{score:.6f}\t{direction}")


if __name__ == "__main__":
    main()

