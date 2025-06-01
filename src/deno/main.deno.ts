/// <reference path="../build/main.ts-interop.d.ts"/>
import { Elm } from "../build/main.esm.js"
import * as Interop from "../build/main.ts-interop.d.ts"

import { concatArray, tryCatch, Result, handleError } from "./util.ts"
import { recursiveReadDirs } from "./recursiveReadDir.ts"

type FsEntry =
    { entry: "File" | "Directory"; path: string }

type EditKind =
    "modify" | "remove" | "any" | "access" | "create" | "other"


//// GLOBALS
const elm: Interop.ElmApp = await tryCatch(
    Elm.Main.init,
    { flags: { fsContext: { current: Deno.cwd() }}},
    "Error initiating elm program"
)
let watcher: undefined | Deno.FsWatcher = undefined
const editedFiles: Set<string> = new Set()
let editTimeOut: number = -1


//// FROM ELM
elm.ports.interopFromElm.subscribe(async (fromElm: Interop.FromElm) => {
    const { toElmList, newWatcher } = await respondToElm(fromElm)

    for (const toElm of toElmList) {
        elm.ports.interopToElm.send(toElm)
    }

    if (newWatcher !== undefined) {
        if (watcher !== undefined) { watcher.close() }
        watcher = newWatcher

        // we use buff and timer to avoid sending multiple time the same event
        let buff = undefined
        let timer = -1
        for await (const event of newWatcher) {
            if (buff === undefined) {
                buff = event
                timer = setTimeout(() => { sendWatchEventToElm(event); buff = undefined }, 20)
            }
            else if (!(JSON.stringify(buff) === JSON.stringify(event))) {
                clearTimeout(timer)
                sendWatchEventToElm(buff)
                buff = event
                timer = setTimeout(() => { sendWatchEventToElm(event) ; buff = undefined }, 20)
            }
        }
    }
})


//// TO ELM
async function respondToElm(fromElm: Interop.FromElm): Promise<{ toElmList: Interop.ToElm[], newWatcher: undefined | Deno.FsWatcher}> {
    switch (fromElm.tag) {
        case "Read": return {
            toElmList: [{
                tag: "ReadResult",
                path: fromElm.path,
                content: await getReadResult(fromElm.path)
            }],
            newWatcher: undefined
        }

        case "RemoteRead": return {
            toElmList: [{
                tag: "RemoteReadResult",
                url: fromElm.url,
                content: await getRemoteReadResult(fromElm.url)
            }],
            newWatcher: undefined
        }

        case "Write":
            return {
                toElmList: [{
                    tag: "WriteResult",
                    path: fromElm.path,
                    result: await getWriteResult(fromElm.path, fromElm.content)
                }],
                newWatcher: undefined
            }

        case "Delete":
            Deno.remove(fromElm.path, {recursive: true})
            return { toElmList: [], newWatcher: undefined }

        case "Watch":
            for (const path of fromElm.paths) {
                try { await Deno.mkdir( path, { recursive: true } ) }
                catch (_) { /* ignore */ }
            }
            return {
                toElmList: [],
                newWatcher: Deno.watchFs(fromElm.paths, { recursive: true })
            }

        case "ReadDirs": return {
            toElmList: [{
                tag: "ReadDirsResult",
                result: await getReadDirsResult(fromElm.paths)
            }],
            newWatcher: undefined
        }

        case "Print":
            console.log(fromElm.message)
            return { toElmList: [], newWatcher: undefined }

        case "Exit": {
            console.log(fromElm.message)
            Deno.exit(1)
            return { toElmList: [], newWatcher: undefined }
        }

        case "Sync": {
            const toElmAcc: Interop.ToElm[][] = []
            let newWatcher = undefined
            for (const syncFromElm of fromElm.fromElmList) {
                // @ts-ignore: syncFromElm is of fromElm type only elm-ts-interop hides it for some reason
                const res = await respondToElm(syncFromElm)
                toElmAcc.push(res.toElmList)
                newWatcher = res.newWatcher ?? newWatcher
            }
            return {
                toElmList: [{
                    tag: "SyncResult",
                    results: concatArray(toElmAcc)
                }],
                newWatcher: newWatcher
            }
        }
    }
}

async function getReadResult(path: string): Promise<Result<string,string>> {
    try {
        return {
            tag: "Ok",
            args: [ await Deno.readTextFile(path) ]
        }
    } catch (e : unknown) { return handleError(e) }
}

async function getRemoteReadResult(url: string): Promise<Result<string,string>> {
    try {
        const res = await fetch(url)
        return {
            tag: "Ok",
            args: [ await res.text() ]
        }
    } catch (e : unknown) { return handleError(e) }
}

async function getWriteResult(path: string, content: string): Promise<Result<string, string>> {
    try {
        if (editedFiles.has(path)) { clearTimeout(editTimeOut) }
        if (editTimeOut !== -1) { clearTimeout(editTimeOut) }
        editTimeOut = setTimeout(() => { editedFiles.delete(path) }, 20)

        await Deno.mkdir( parentDirectory(path), { recursive: true } )
        await Deno.writeTextFile(path, content)
        return {
            tag: "Ok",
            args: [ content ]
        }
    } catch (e) { return handleError(e) }
}

async function getReadDirsResult(dirPaths: string[]): Promise<Result<string, FsEntry[]>> {
    try {
        return {
            tag: "Ok",
            args: [ await recursiveReadDirs(dirPaths) ]
        }
    } catch (e : unknown) { return handleError(e) }
}

function parentDirectory(path:string): string {
    const pathArr = path.split("/")
    pathArr.pop()
    return pathArr.join("/")
}

function sendWatchEventToElm(event: Deno.FsEvent): void {
    event.paths.forEach(path => {
        // behavior of Deno.watchFs on different platforms : https://github.com/tommywalkie/Deno.watchFs
        //TODO get proper remove events when a file is moved
        //TODO make sure it isn't a directory

        if (editedFiles.has(path)) {
            const edit =
                event.kind === "modify" ? "Modify" :
                event.kind === "remove" ? "Remove" :
                null // ignore "access" and "create"

            if (edit != null) {
                console.log(event.kind + ": " + path)
                elm.ports.interopToElm.send({
                    tag: "WatchEvent",
                    path: path,
                    edit: edit
                })
            }
        }
    })
}
