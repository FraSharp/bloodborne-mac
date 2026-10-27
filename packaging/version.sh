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

# The version line and nothing else: these files are hand formatted (tauri.conf.json keeps one-line
# objects), so they are rewritten by pattern rather than through a JSON parser, and a file whose
# shape changed stops the script instead of being reformatted.
def replace(path, pattern, version):
    text = files[path].read_text()
    changed, found = re.subn(pattern, rf"\g<1>{version}\g<2>", text, count=1, flags=re.M | re.S)
    if found != 1:
        raise SystemExit(f"{path}: no version line where it was expected, not touching it")
    files[path].write_text(changed)

def write(version):
    replace("package.json", r'^(\s*"version": ")[^"]+(")', version)
    replace("package-lock.json", r'(^  "name": "bloodborne-launcher",\n  "version": ")[^"]+(")',
            version)
    replace("package-lock.json", r'(^      "name": "bloodborne-launcher",\n      "version": ")[^"]+(")',
            version)
    replace("Cargo.toml", r'(^\[package\].*?^version = ")[^"]+(")', version)
    replace("Cargo.lock", r'(^name = "bloodborne-launcher"\nversion = ")[^"]+(")', version)
    replace("tauri.conf.json", r'^(\s*"version": ")[^"]+(")', version)

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
    # With a tag: an exact match, or its release version, because a pre-release tag (v0.9.0-rc.1)
    # keeps 0.9.0 in the files (the app and its launcher carry the release) and the tag is what
    # makes it a candidate. Without one (manual and scheduled runs) the files only have to agree.
    if len(args) > 1:
        tag = args[1].lstrip("v")
        release = re.sub(r"-(rc|beta|alpha)\.\d+$", "", tag)
        if version not in (tag, release):
            raise SystemExit(f"the tag says {tag}, the files say {version}")
    print(version)
else:
    write(args[0].lstrip("v"))
    for name in sorted(files):
        print(f"  {name}: {args[0].lstrip('v')}")
PY
