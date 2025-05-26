import { notNull, concatArray, unique } from "./util.ts"

export async function recursiveReadDirs(paths: string[], ignoreList: RegExp[] = [], ignoreFileName: string | null = null): Promise<{ path: string, entry: "File" | "Directory" }[]> {
    const result: { path: string, entry: "File" | "Directory" }[][] = await Promise.all<{ path: string, entry: "File" | "Directory" }[]>(
        paths.map((path) => {
            return recursiveReadDir(path, ignoreList, ignoreFileName)
        })
    )

    return unique(concatArray(result))
}


export async function recursiveReadDir(path: string, ignoreList: RegExp[] = [], ignoreFileName: string | null = null): Promise<{ path: string, entry: "File" | "Directory" }[]> {
    const dirEntries: Deno.DirEntry[] = []
    let newIgnoreList: RegExp[] = ignoreList
    let acc: { path: string, entry: "File" | "Directory" }[] = []

    for await (const dirEntry of Deno.readDir(path)) {
        dirEntries.push(dirEntry)

        if (notNull(ignoreFileName) && dirEntry.name === ignoreFileName) {
            newIgnoreList = await addIgnoreFile(path, ignoreFileName, newIgnoreList)
        }
    }

    for (const dirEntry of dirEntries) {
        const next_path = `${path}/${dirEntry.name}`
        if (!isInIgnoreList(next_path, newIgnoreList)) {
            if (dirEntry.isDirectory) {
                acc.push({ path: next_path, entry: "Directory" })
                acc = acc.concat(await recursiveReadDir(next_path, newIgnoreList, ignoreFileName))
            } else if (dirEntry.isFile) {
                acc.push({ path: next_path, entry: "File" })
            }
        }
    }

    return acc
}

async function addIgnoreFile(path: string, ignoreFileName: string, ignoreList: RegExp[]): Promise<RegExp[]> {
    const ignoreFileContent: string[] = (await Deno.readTextFile(`${path}/${ignoreFileName}`)).split(/\r?\n/)

    ignoreFileContent.pop()

    const ignoreFileContentRegex: RegExp[] = ignoreFileContent
        .map((ignoredPath) => {
            const regex = `${path}/${ignoredPath}`
                .replace(/[.+?^${}()/|[\]\\]/g, '\\$&')
                .replace(/[*]/g, '.*')
            return new RegExp(`^${regex}$`)
        })

    return ignoreList.concat(ignoreFileContentRegex)
}

function isInIgnoreList(path: string, ignoreList: RegExp[]): boolean {
    for (const ignoreRegex of ignoreList) {
        if (ignoreRegex.test(path)) {
            console.log(`"${ignoreRegex.source}" =match=> "${path}"`)
            return true
        }
    }
    return false
}
