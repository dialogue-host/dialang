#!/usr/bin/env bash

p=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )/..

echo "---- BUILDING DIALANG CLI ----"

rm -rf $p/build
mkdir $p/build
npx elm-ts-interop \
    --output $p/build/main.ts-interop.d.ts \
    --definition-module Ts \
    --entrypoint Main
elm make $p/elm/Main.elm --output=$p/build/main.js
$p/bin/elm-esm.deno.ts $p/build/main.js > $p/build/main.esm.js
