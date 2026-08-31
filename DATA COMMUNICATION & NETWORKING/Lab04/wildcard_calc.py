"""
Data Communication and Networking --- Lab 4 helper: wildcard mask calculator.

OSPF network statements take a WILDCARD mask, which is the bitwise inverse
of a subnet mask. This converts between the three notations and shows the
working, so you can check answers you have done by hand.

Do a few by hand first. The conversion appears in examinations, and a
calculator you cannot reproduce on paper is not much use there.

Run:
    py wildcard_calc.py 192.168.1.0/24
    py wildcard_calc.py 10.0.12.0 255.255.255.252
    py wildcard_calc.py --table
"""

from __future__ import annotations

import sys


def octets(value: str) -> list[int]:
    parts = value.split(".")
    if len(parts) != 4:
        raise ValueError(f"{value!r} is not a dotted quad")

    result = []
    for part in parts:
        n = int(part)
        if not 0 <= n <= 255:
            raise ValueError(f"octet {n} out of range in {value!r}")
        result.append(n)
    return result


def mask_from_prefix(prefix: int) -> list[int]:
    if not 0 <= prefix <= 32:
        raise ValueError(f"prefix /{prefix} out of range")

    bits = "1" * prefix + "0" * (32 - prefix)
    return [int(bits[i:i + 8], 2) for i in range(0, 32, 8)]


def wildcard(mask: list[int]) -> list[int]:
    """Bitwise inverse: subtract each octet from 255."""
    return [255 - o for o in mask]


def network_address(addr: list[int], mask: list[int]) -> list[int]:
    """AND the address with the mask to zero the host bits."""
    return [a & m for a, m in zip(addr, mask)]


def describe(address: str, mask_spec: str) -> None:
    addr = octets(address)

    if mask_spec.startswith("/"):
        prefix = int(mask_spec[1:])
        mask = mask_from_prefix(prefix)
    else:
        mask = octets(mask_spec)
        prefix = sum(bin(o).count("1") for o in mask)

    wc = wildcard(mask)
    net = network_address(addr, mask)
    hosts = 2 ** (32 - prefix)

    def dotted(o: list[int]) -> str:
        return ".".join(str(x) for x in o)

    print(f"  address        {dotted(addr)}")
    print(f"  prefix         /{prefix}")
    print(f"  subnet mask    {dotted(mask)}")
    print(f"  wildcard mask  {dotted(wc)}   <-- use this in OSPF")
    print(f"  network        {dotted(net)}")
    print(f"  addresses      {hosts:,}")

    if dotted(net) != dotted(addr):
        print(f"\n  NOTE: {dotted(addr)} is a host address, not a network address.")
        print(f"        The network is {dotted(net)}. Write that in the")
        print(f"        network statement, with host bits zeroed.")

    print(f"\n  ospf 1")
    print(f"   area 0")
    print(f"    network {dotted(net)} {dotted(wc)}")

    print("\n  working (255 - each mask octet):")
    for m, w in zip(mask, wc):
        print(f"    255 - {m:>3} = {w:>3}")


def table() -> None:
    print(f"  {'prefix':>7}  {'subnet mask':>16}  {'wildcard':>16}  {'addresses':>10}")
    print("  " + "-" * 56)
    for prefix in [8, 16, 24, 25, 26, 27, 28, 29, 30, 32]:
        mask = mask_from_prefix(prefix)
        wc = wildcard(mask)
        print(f"  {'/' + str(prefix):>7}  "
              f"{'.'.join(map(str, mask)):>16}  "
              f"{'.'.join(map(str, wc)):>16}  "
              f"{2 ** (32 - prefix):>10,}")

    print("\n  A 0 bit in a wildcard means 'this bit must match'.")
    print("  A 1 bit means 'do not care'. So 0.0.0.255 fixes the first")
    print("  three octets and frees the last --- exactly a /24.")


def main() -> None:
    args = sys.argv[1:]

    if not args or args[0] in {"-h", "--help"}:
        print(__doc__)
        return

    if args[0] == "--table":
        table()
        return

    try:
        if "/" in args[0]:
            address, prefix = args[0].split("/", 1)
            describe(address, "/" + prefix)
        elif len(args) == 2:
            describe(args[0], args[1])
        else:
            sys.exit("usage: py wildcard_calc.py ADDRESS/PREFIX | ADDRESS MASK | --table")
    except ValueError as exc:
        sys.exit(f"error: {exc}")


if __name__ == "__main__":
    main()
