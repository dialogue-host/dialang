#!/usr/bin/env bash

p=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )/..

echo "---- RUNNING DIALANG CLI ----"
deno run \
    --allow-read --allow-write --allow-env --allow-run --allow-net \
    $p/deno/main.deno.ts
