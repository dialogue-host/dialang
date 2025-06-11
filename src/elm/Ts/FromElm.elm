module Ts.FromElm exposing (toString)

import Ts exposing (..)
import Fs.Path
import Url

toString : FromElm -> String
toString fromElm =
    let
        pathListStr pathList =
            List.map Fs.Path.toString pathList
            |> listStr

        listStr strList =
            List.intersperse "\n\t, " strList
            |> List.foldr (++) ""
    in
    case fromElm of
        Read path ->
            "Read " ++ Fs.Path.toString path

        RemoteRead url ->
            "RemoteRead " ++ Url.toString url

        Write path str ->
            "Write "
            ++ Fs.Path.toString path
            ++ shortString str

        Delete path ->
            "Delete " ++ Fs.Path.toString path

        Watch pathList ->
            "Watch\n\t[ "
            ++ pathListStr pathList
            ++ "\n\t]"

        ReadDirs pathList ->
            "ReadDirs\n\t[ "
            ++ pathListStr pathList
            ++ "\n\t]"

        Print str ->
            "Print \""
            ++ String.slice 0 10 str
            ++ "[...]\""

        Exit str ->
            "Exit" ++ shortString str

        Sync listFromElm ->
            "Sync\n\t[ "
            ++ (listStr <| List.map toString listFromElm)
            ++ "\n\t]"

---- Util ----

shortString str =
    " \""
    ++ String.slice 0 10 str
    ++ "[...]\""
