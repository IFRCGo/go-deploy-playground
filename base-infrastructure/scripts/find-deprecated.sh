#!/bin/bash

# Lists deprecated provider arguments that the terraform config still uses.
#
# Reads the deprecation flags out of `terraform providers schema`, so it reports every
# deprecated argument the providers know about rather than only the ones a given plan
# happens to reach. Needs no cloud credentials and no state.
#
# Usage: base-infrastructure/scripts/find-deprecated.sh

set -e

TF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../terraform" && pwd)"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

# Copy the config out of the way so `init` neither touches the real .terraform nor asks
# for the remote backend.
cp -r "$TF_DIR/." "$WORK/"
cp "$TF_DIR/../../.terraform-version" "$WORK/" 2>/dev/null || true
rm -rf "$WORK/.terraform" "$WORK/backend.tf"

(cd "$WORK" && terraform init -backend=false >/dev/null)
(cd "$WORK" && terraform providers schema -json) > "$WORK/schema.json"

SCHEMA="$WORK/schema.json" python3 - "$TF_DIR" <<'PY'
import json, os, re, sys

tf_dir = sys.argv[1]
schema = json.load(open(os.environ["SCHEMA"]))

# resource type -> {deprecated argument name}
deprecated = {}


def walk(block, sink):
    for name, spec in (block.get("attributes") or {}).items():
        if spec.get("deprecated"):
            sink.add(name)
    for name, spec in (block.get("block_types") or {}).items():
        if spec.get("deprecated"):
            sink.add(name)
        walk(spec.get("block", {}), sink)


for provider in schema.get("provider_schemas", {}).values():
    for kind in ("resource_schemas", "data_source_schemas"):
        for rtype, rschema in (provider.get(kind) or {}).items():
            sink = deprecated.setdefault(rtype, set())
            walk(rschema.get("block", {}), sink)

block_re = re.compile(r'^\s*(resource|data)\s+"([^"]+)"\s+"([^"]+)"')
arg_re = re.compile(r'^\s*([a-z0-9_]+)\s*=')
nested_re = re.compile(r'^\s*([a-z0-9_]+)\s*\{')

findings = []
for root, dirs, files in os.walk(tf_dir):
    dirs[:] = [d for d in dirs if d != ".terraform"]
    for fname in sorted(files):
        if not fname.endswith(".tf"):
            continue
        path = os.path.join(root, fname)
        rtype = None
        for lineno, line in enumerate(open(path), 1):
            if line.lstrip().startswith("#"):
                continue
            m = block_re.match(line)
            if m:
                rtype = m.group(2)
                continue
            if not rtype:
                continue
            m = arg_re.match(line) or nested_re.match(line)
            if m and m.group(1) in deprecated.get(rtype, ()):
                rel = os.path.relpath(path, tf_dir)
                findings.append((rel, lineno, rtype, m.group(1)))

if not findings:
    print("No deprecated provider arguments in use.")
else:
    width = max(len(f"{f}:{l}") for f, l, _, _ in findings)
    for f, l, rtype, arg in findings:
        print(f"{f}:{l}".ljust(width), f"{rtype}.{arg}")
    print(f"\n{len(findings)} deprecated argument(s) in use.")
PY
