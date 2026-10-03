#!/usr/bin/env python3
"""Bounded symbolic path generator for Lang-1 NumberUtils.createNumber hex branch.

This models only the hex-dispatch branch; it is not a Java symbolic VM.
The path bounds and runtime outputs are recorded for reproducibility.
"""
import argparse
import hashlib
import json
import re
from pathlib import Path

CLASS = "NumberUtilsSymbolicHexTest"
PACKAGE = "org.apache.commons.lang3.math"


def intersect(a, b):
    low, high = max(a[0], b[0]), min(a[1], b[1])
    return (low, high) if low <= high else None


def solve_path(bounds, constraints):
    """Propagate integer interval constraints, returning satisfiable witnesses."""
    current = bounds
    for relation, value in constraints:
        if relation == ">":
            domain = (value + 1, bounds[1])
        elif relation == "<=":
            domain = (bounds[0], value)
        elif relation == ">=":
            domain = (value, bounds[1])
        else:
            raise ValueError(relation)
        current = intersect(current, domain)
        if current is None:
            return None
    return current


def java_source(cases):
    methods = []
    for i, case in enumerate(cases):
        methods.append(
            "    @Test public void path_%02d() {\n" % i
            + '        Number actual = NumberUtils.createNumber("%s");\n' % case["input"]
            + '        assertEquals(new BigInteger("%d"),\n' % case["expected"]
            + '            new BigInteger(actual.toString()));\n'
            + "    }\n"
        )
    return ("package " + PACKAGE + ";\n"
            "import java.math.BigInteger;\nimport org.junit.Test;\n"
            "import static org.junit.Assert.assertEquals;\n"
            "public class " + CLASS + " {\n" + "\n".join(methods) + "}\n")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source", type=Path, required=True,
                        help="Original buggy NumberUtils.java from Defects4J Lang-1b")
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    source = args.source.read_text()
    start = source.index("public static Number createNumber(")
    end = source.index("final char lastChar", start)
    dispatch = source[start:end]
    # Stop if the control flow differs from the branch whose constraints we model.
    for expression in (r"hexDigits\s*>\s*16", r"hexDigits\s*>\s*8",
                       r"return createBigInteger\(str\)", r"return createLong\(str\)",
                       r"return createInteger\(str\)"):
        if not re.search(expression, dispatch):
            raise RuntimeError("Unrecognized source branch: " + expression)

    cases = []
    paths = []
    seen = set()
    # The source dispatches on hexadecimal digit count. Symbolic magnitude
    # also crosses the signed Integer boundary *within* the <=8 digit path.
    for digits in (1, 8, 9, 16, 17):
        digit_domain = (16 ** (digits - 1) if digits > 1 else 0,
                        16 ** digits - 1)
        if digits > 16:
            branch = ((">", 16),)
        elif digits > 8:
            branch = (("<=", 16), (">", 8))
        else:
            branch = (("<=", 16), ("<=", 8))
        assert solve_path((digits, digits), branch)
        for sign in (1, -1):
            # Signed Java Integer range changes at different magnitudes for
            # positive and negative inputs; the numeric oracle is independent.
            integer_limit = 0x7FFFFFFF if sign > 0 else 0x80000000
            for magnitude_branch in (("<=", integer_limit), (">", integer_limit)):
                solved = solve_path(digit_domain, (magnitude_branch,))
                if solved is None:
                    continue
                # Sample both endpoints to exercise boundaries of each path.
                for magnitude in sorted(set(solved)):
                    literal = ("-" if sign < 0 else "") + "0x" + format(magnitude, "X").zfill(digits)
                    if literal in seen:
                        continue
                    seen.add(literal)
                    case = {"input": literal, "expected": sign * magnitude,
                            "hex_digits": digits, "source_dispatch": [list(x) for x in branch],
                            "signed_integer_constraint": list(magnitude_branch),
                            "solved_magnitude_interval": list(solved)}
                    cases.append(case)
                    paths.append({"input": literal, "branch": ">16" if digits > 16 else
                                  ">8" if digits > 8 else "<=8",
                                  "expected": sign * magnitude})

    args.output.mkdir(parents=True, exist_ok=False)
    (args.output / (CLASS + ".java")).write_text(java_source(cases))
    (args.output / "paths.json").write_text(json.dumps({
        "method": PACKAGE + ".NumberUtils.createNumber(String)",
        "source_sha256": hashlib.sha256(args.source.read_bytes()).hexdigest(),
        "source_path": str(args.source),
        "scope": "Hexadecimal dispatch only; bounded integer interval symbolic model",
        "source_digit_guards": [">16", ">8", "<=8"],
        "cases": cases,
    }, indent=2) + "\n")
    print("Solved", len(paths), "path-boundary inputs")
    print("Java test class:", args.output / (CLASS + ".java"))


if __name__ == "__main__":
    main()
