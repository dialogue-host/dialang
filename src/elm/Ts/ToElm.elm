module Ts.ToElm exposing (toString)

import Ts exposing (..)
import Fs.Path
import Fs
import Url

toString : ToElm v -> String
toString toElm =
    case toElm of
        WatchEvent path edit ->
            "WatchEvent " ++ Fs.Path.toString path ++ " " ++ editToString edit

        ReadResult path result ->
            "ReadResult " ++ Fs.Path.toString path ++ " " ++ resultToString result

        RemoteReadResult url result ->
            "RemoteReadResult " ++ Url.toString url ++ " " ++ resultToString result

        WriteResult path result ->
            "WriteResult " ++ Fs.Path.toString path ++ " " ++ resultToString result

        ReadDirsResult result ->
            "ReadDirsResult " ++ readDirsResultToString result

        SyncResult results ->
            "SyncResult\n\t[ " ++ (results |> List.map toString |> String.join "\n\t, ") ++ "\n\t]"


---- Utils ----

editToString : Edit -> String
editToString edit =
    case edit of
        Remove -> "Remove"
        Modify -> "Modify"


resultToString : Result String String -> String
resultToString result =
    case result of
        Ok val -> "(Ok" ++ shortString val ++ ")"
        Err err -> "(Err" ++ shortString err ++ ")"


readDirsResultToString : Result String (List { path : Fs.Path, isFile : Bool }) -> String
readDirsResultToString result =
    case result of
        Ok entries ->
            List.map
                (\entry ->
                    if entry.isFile then
                        "File " ++ Fs.Path.toString entry.path
                    else
                        "Dir " ++ Fs.Path.toString entry.path
                )
                entries
            |> String.join ", "
            |> (\s -> "(Ok [" ++ s ++ "])")
        Err err ->
            "(Err " ++ err ++ ")"


shortString str =
    " \""
    ++ String.slice 0 10 str
    ++ "[...]\""
