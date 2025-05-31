module Fs.Path exposing (..)

import Fs exposing (..)
import NeList


baseName : Path -> String
baseName (Path path) =
    NeList.last path


fileExtension : Path -> Maybe String
fileExtension path =
    baseName path
        |> String.split "."
        |> List.tail
        |> Maybe.map
            (List.intersperse "."
                >> (::) "."
                >> List.foldr (++) ""
            )


insertRight : Path -> String -> Path
insertRight (Path ( head, queue )) str =
    Path ( head, queue ++ (String.split "/" str |> List.filter ((/=) "")) )

insertLeft : String -> Path -> Path
insertLeft str (Path (head, queue)) =
    case String.split "/" str of
        [] -> Path (head, queue)
        nameHead :: nameQueue ->
            Path (nameHead, nameQueue ++ head :: queue)

fromString : String -> Maybe Path
fromString str =
    --TODO secure this
    case String.split "/" str of
        head :: queue ->
            Path ( head, queue |> List.filter ((/=) "") )
                |> Just

        _ ->
            Nothing


toString : Path -> String
toString (Path path) =
    NeList.toList path
        |> String.join "/"


toList : Path -> List String
toList (Path path) =
    NeList.toList path


join : Path -> Path -> Path
join (Path ( head, queue )) (Path ( head2, queue2 )) =
    Path ( head, queue ++ (head2 :: queue2) )


home : Path
home =
    Path ( "~", [] )


current : Path
current =
    Path ( ".", [] )


root : Path
root =
    Path ( "", [] )


toRelative : Context -> Path -> Path
toRelative context path_ =
    let path = toAbsolute context path_ in
    case path of
        Path ( ".", _ ) -> path

        Path ( "~", [] ) ->
            sever context.current context.home
            |> Maybe.withDefault context.home

        Path ( "~", h :: q ) ->
            let abs = join context.home (Path (h, q)) in
            sever context.current abs
            |> Maybe.withDefault abs

        Path ( "", _ ) ->
            sever context.current path
            |> Maybe.withDefault path

        _ -> join current path


toAbsolute : Context -> Path -> Path
toAbsolute context path =
    let
        newPath =
            case path of
                Path ( ".", [] ) -> context.current

                Path ( ".", h :: q ) ->
                    join context.current (Path (h, q))

                Path ( "~", [] ) -> context.home

                Path ( "~", h :: q ) ->
                    join context.home (Path (h, q))

                Path ( "", _ ) -> path

                other -> join context.current other
    in
    reduce newPath


{-|
    Reduces `./hello//./small/../world` to `./hello/world` while keeping the front `../`, `./` and `/`.
-}
reduce : Path -> Path
reduce (Path (head, queue)) =
    let
        isNotSpecial str =
            List.member str ["..", ".", "~", ""] |> not

        loop (l, c, r) =
            case (l, c, r) of
                (hl :: ql, "..", hr :: qr) ->
                    if isNotSpecial hl
                    then loop (ql, hr, qr)
                    else loop (".." :: hl :: ql, hr, qr)
                (hl :: hhl :: ql, "..", []) ->
                    if isNotSpecial hl
                    then NeList.reverse (hhl, ql)
                    else NeList.reverse ("..", hl :: hhl :: ql)
                (_ :: _, ".", hr :: qr) ->
                    loop (l, hr, qr)
                (_ :: _, "", hr :: qr) ->
                    loop (l, hr, qr)
                (_, _, hr :: qr) ->
                    loop (c :: l, hr, qr)
                (_, _, []) ->
                    NeList.reverse (c, l)
    in
    loop ([], head, queue) |> Path


{-|

    sever `./src/foo` `./src/foo/bar/hello.world`
    --> Just `bar/hello.world`

    Returns `Nothing` if the first path doesn't match the beginning of the second.

-}
sever : Path -> Path -> Maybe Path
sever basePath path =
    let
        (Path ( basePathHead, basePathQueue )) =
            basePath

        (Path ( pathHead, pathQueue )) =
            path
    in
    if basePathHead /= pathHead then
        Nothing

    else
        case ( basePathQueue, pathQueue ) of
            ( basePathQueueHead :: basePathQueueQueue, pathQueueHead :: pathQueueQueue ) ->
                sever
                    (Path ( basePathQueueHead, basePathQueueQueue ))
                    (Path ( pathQueueHead, pathQueueQueue ))

            ( [], pathQueueHead :: pathQueueQueue ) ->
                Path ( pathQueueHead, pathQueueQueue )
                    |> Just

            _ ->
                Nothing
