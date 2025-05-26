module Fs.Path exposing (..)

import Fs
import NeList


baseName : Fs.Path -> String
baseName (Fs.Path path) =
    NeList.last path


extension : Fs.Path -> Maybe String
extension path =
    baseName path
        |> String.split "."
        |> List.tail
        |> Maybe.map
            (List.intersperse "."
                >> (::) "."
                >> List.foldr (++) ""
            )


dirChild : Fs.Path -> String -> Fs.Path
dirChild (Fs.Path ( head, queue )) name =
    Fs.Path ( head, queue ++ (String.split "/" name |> List.filter ((/=) "")) )


fromString : String -> Maybe Fs.Path
fromString str =
    --TODO secure this
    case String.split "/" str of
        head :: queue ->
            Fs.Path ( head, queue |> List.filter ((/=) "") )
                |> Just

        _ ->
            Nothing


toString : Fs.Path -> String
toString (Fs.Path path) =
    NeList.toList path
        |> String.join "/"


toList : Fs.Path -> List String
toList (Fs.Path path) =
    NeList.toList path


join : Fs.Path -> Fs.Path -> Fs.Path
join (Fs.Path ( head, queue )) (Fs.Path ( head2, queue2 )) =
    Fs.Path ( head, queue ++ (head2 :: queue2) )


home : Fs.Path
home =
    Fs.Path ( "~", [] )


current : Fs.Path
current =
    Fs.Path ( ".", [] )


root : Fs.Path
root =
    Fs.Path ( "", [] )


toRelative : Fs.Path -> Fs.Path -> Maybe Fs.Path
toRelative pwd path =
    removeBase pwd path
        |> Maybe.map
            (\p ->
                case p of
                    Fs.Path ( head, queue ) ->
                        Fs.Path ( ".", head :: queue )
            )


{-|

    removePathBase `./src/foo` `./src/foo/bar/hello.world`
    --> Just `bar/hello.world`

-}
removeBase : Fs.Path -> Fs.Path -> Maybe Fs.Path
removeBase basePath path =
    let
        (Fs.Path ( basePathHead, basePathQueue )) =
            basePath

        (Fs.Path ( pathHead, pathQueue )) =
            path
    in
    if basePathHead /= pathHead then
        Nothing

    else
        case ( basePathQueue, pathQueue ) of
            ( basePathQueueHead :: basePathQueueQueue, pathQueueHead :: pathQueueQueue ) ->
                removeBase
                    (Fs.Path ( basePathQueueHead, basePathQueueQueue ))
                    (Fs.Path ( pathQueueHead, pathQueueQueue ))

            ( [], pathQueueHead :: pathQueueQueue ) ->
                Fs.Path ( pathQueueHead, pathQueueQueue )
                    |> Just

            _ ->
                Nothing
