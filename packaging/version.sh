#!/usr/bin/env bash
# The app's version is one number in six places that have to agree: the launcher's package.json,
# its lock file (twice), Cargo.toml, Cargo.lock and tauri.conf.json. A release adds the git tag, and
# that is what this checks against.
#   bash packaging/version.sh 0.9.1          # write it everywhere
#   bash packaging/version.sh --check         # do the six agree?
#   bash packaging/version.sh --check v0.9.1  # and with this tag? (the workflow on a tag)
set -euo pipefail
cd -- "$(dirname -- "$0")/.."
python3 - "$@" <<'PY'
import json, pathlib, re, sys

launcher = pathlib.Path("launcher")
files = {
    "package.json": launcher / "package.json",
    "package-lock.json": launcher / "package-lock.json",
    "Cargo.toml": launcher / "src-tauri" / "Cargo.toml",
    "Cargo.lock": launcher / "src-tauri" / "Cargo.lock",
    "tauri.conf.json": launcher / "src-tauri" / "tauri.conf.json",
}

def read_versions():
    found = {}
    found["package.json"] = json.loads(files["package.json"].read_text())["version"]
    lock = json.loads(files["package-lock.json"].read_text())
    found["package-lock.json"] = lock["version"]
    if lock["packages"][""]["version"] != lock["version"]:
        found["package-lock.json"] += f"/{lock['packages']['']['version']}"
    cargo = files["Cargo.toml"].read_text()
    found["Cargo.toml"] = re.search(r'^\[package\].*?^version = "([^"]+)"', cargo, re.M | re.S).group(1)
    cargolock = files["Cargo.lock"].read_text()
    found["Cargo.lock"] = re.search(
        r'^name = "bloodborne-launcher"\nversion = "([^"]+)"', cargolock, re.M).group(1)
    found["tauri.conf.json"] = json.loads(files["tauri.conf.json"].read_text())["version"]
    return found

def write(version):
    package = json.loads(files["package.json"].read_text())
    package["version"] = version
    files["package.json"].write_text(json.dumps(package, indent=2) + "\n")

    lock = json.loads(files["package-lock.json"].read_text())
    lock["version"] = version
    lock["packages"][""]["version"] = version
    files["package-lock.json"].write_text(json.dumps(lock, indent=2) + "\n")

    cargo = files["Cargo.toml"].read_text()
    files["Cargo.toml"].write_text(re.sub(
        r'(^\[package\].*?^version = ")[^"]+(")', rf'\g<1>{version}\g<2>', cargo, count=1,
        flags=re.M | re.S))

    cargolock = files["Cargo.lock"].read_text()
    files["Cargo.lock"].write_text(re.sub(
        r'(^name = "bloodborne-launcher"\nversion = ")[^"]+(")', rf'\g<1>{version}\g<2>', cargolock,
        count=1, flags=re.M))

    tauri = json.loads(files["tauri.conf.json"].read_text())
    tauri["version"] = version
    files["tauri.conf.json"].write_text(json.dumps(tauri, indent=2) + "\n")

args = sys.argv[1:]
if not args:
    raise SystemExit("usage: packaging/version.sh <version> | --check [tag]")
if args[0] == "--check":
    versions = read_versions()
    names = sorted(versions)
    if len({versions[n] for n in names}) != 1:
        for n in names:
            print(f"  {n}: {versions[n]}")
        raise SystemExit("the launcher's version differs between these files")
    version = versions[names[0]]
    # A pre-release tag (v0.9.0-rc.1) keeps the release version in the files: the app and its
    # launcher carry 0.9.0, and the tag is what makes it a candidate.
    tag = args[1].lstrip("v")
    release = re.sub(r"-(rc|beta|alpha)\.\d+$", "", tag)
    if len(args) > 1 and version not in (tag, release):
        raise SystemExit(f"the tag says {tag}, the files say {version}")
    print(version)
else:
    write(args[0].lstrip("v"))
    for name in sorted(files):
        print(f"  {name}: {args[0].lstrip('v')}")
PY
