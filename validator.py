"""Validator node helper script

This script is intended to be run inside the validator container defined in
`docker-compose.yml`. It periodically scans the shared `/app/data` volume for
pairs of data files and accompanying SHA-256 checksum files. When a mismatch is
found it executes the project-level `verify.sh` script which performs a full
verification run and can be extended to send alerts or quarantine bad chunks.

Checksum file format: for a file `foo.bin` there should be a sibling
`foo.bin.sha256` containing the hex digest (optionally followed by a filename).
"""

import hashlib
import os
import subprocess
import sys

DATA_DIR = "/app/data"
CHECK_EXT = ".sha256"


def compute_sha256(path: str) -> str:
    """Compute SHA-256 digest of the given file."""
    h = hashlib.sha256()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(8192), b""):
            h.update(chunk)
    return h.hexdigest()


def verify_files():
    mismatches = []
    for root, _, files in os.walk(DATA_DIR):
        for fname in files:
            if fname.endswith(CHECK_EXT):
                data_fname = fname[: -len(CHECK_EXT)]
                data_path = os.path.join(root, data_fname)
                check_path = os.path.join(root, fname)
                if not os.path.exists(data_path):
                    continue

                with open(check_path, "r") as cf:
                    expected = cf.read().strip().split()[0]

                actual = compute_sha256(data_path)
                if actual != expected:
                    mismatches.append((data_path, expected, actual))
    if mismatches:
        print("Integrity mismatches detected:")
        for path, exp, act in mismatches:
            print(f"  {path}: expected {exp}, got {act}")
        # trigger global verification
        try:
            subprocess.run(["/bin/bash", "./verify.sh"], check=True)
        except subprocess.CalledProcessError:
            print("verify.sh failed", file=sys.stderr)
    else:
        print("All files verified successfully.")


if __name__ == "__main__":
    verify_files()
