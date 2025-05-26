#!/usr/bin/env deno run --allow-read

const path = Deno.args[0]
try {
    const content = await Deno.readTextFile(path)
    const out = compiledElmToESModule(content)
    if (out === null) {
        await stdout("Error : Improper compiled elm code\n")
        Deno.exit(1)
    } else {
        await stdout(out)
    }
} catch (e) {
    await stdout("Error : " + e.message + "\n")
    Deno.exit(2)
}

async function stdout(str: string): Promise<void> {
    const uint8array = new TextEncoder().encode(str)
    await Deno.stdout.write(uint8array)
}

// this is a ts version of https://github.com/ChristophP/elm-esm/blob/master/src/index.js
// return null if invalid compiled elm code
function compiledElmToESModule(js: string): string | null {
    const elmExports = js.match(/^\s*_Platform_export\(([^]*)\);\n?}\(this\)\);/m)
    if (elmExports === null) { return null }
    else {
        return js
            .replace(/\(function\s*\(scope\)\s*\{$/m, "// -- $&")
            .replace(/['"]use strict['"];$/m, "// -- $&")
            .replace(/function _Platform_export([^]*?)\}\n/g, "/*\n$&\n*/")
            .replace(/function _Platform_mergeExports([^]*?)\}\n\s*}/g, "/*\n$&\n*/")
            .replace(/^\s*_Platform_export\(([^]*)\);\n?}\(this\)\);/m, "/*\n$&\n*/")
            .concat(`\nexport const Elm = ${elmExports[1]};\n`)
    }
}
