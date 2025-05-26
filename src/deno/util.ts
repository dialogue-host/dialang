export function notNull<TValue>(value: TValue | null): value is TValue {
    return value !== null
}

export function fold<A, B>(reducer: (x: A, acc: B) => B, init: B, xs: A[]): B {
    let acc = init
    for (const x of xs) {
        acc = reducer(x, acc)
    }
    return acc
}

export function concatArray<T>(xs: T[][]): T[] {
    function myConcat(x: T[], acc: T[]): T[] {
        return acc.concat(x)
    }
    return fold(myConcat, [], xs)
}

export function unique<T>(arr: T[]): T[] {
    const uniqueArr: T[] = []
    for (const item of arr) {
        const isUnique = uniqueArr.findIndex((uniqueItem) => {
            return JSON.stringify(item) === JSON.stringify(uniqueItem)
        })
        if (isUnique <= -1) {
            uniqueArr.push(item)
        }
    }
    return uniqueArr
}

export function tryCatch<A, B>(func: (a: A) => B, a: A, errorTitle: string): B {
    try {
        return func(a)
    } catch (e) {
        if (e instanceof Error) {
            console.error(`${errorTitle}: ${e.message}\n`)
            Deno.exit(1)
        } else {
            console.error(`${errorTitle}: Error isn't an instance of Error class.\n`)
            Deno.exit(1)
        }
    }
}

export type Result<Err, Ok> =
    { tag: "Ok"; args: [Ok] } | { tag: "Err"; args: [Err] }

export function handleError<ok>(e : unknown):Result<string, ok> {
    if (e instanceof Error) {
        return {
            tag: "Err",
            args: [ e.message ]
        }
    } else {
        return {
            tag: "Err",
            args: [ "Threw an error that isn't an instance of Error." ]
        }
    }
}
