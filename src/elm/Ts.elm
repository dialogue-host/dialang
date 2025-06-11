port module Ts exposing
    ( Edit(..)
    , Flags
    , FromElm(..)
    , ToElm(..)
    , decodeFlags
    , interop
    , send
    , subscribe
    )

import Dict
import Fs
import Fs.Path
import Json.Decode as D
import Json.Encode as E
import Result.Extra
import TsJson.Codec as TsC
import TsJson.Decode as TsD
import TsJson.Encode as TsE
import Url exposing (Url)


interop :
    { toElm : TsD.Decoder (ToElm v)
    , fromElm : TsE.Encoder FromElm
    , flags : TsD.Decoder Flags
    }
interop =
    { toElm = TsC.decoder toElmCodec
    , fromElm = TsC.encoder fromElmCodec
    , flags = TsC.decoder flagsCodec
    }


type ToElm v
    = WatchEvent Fs.Path Edit
    | ReadResult Fs.Path (Result String String)
    | RemoteReadResult Url (Result String String)
    | WriteResult Fs.Path (Result String String)
    | ReadDirsResult (Result String (List {isFile : Bool, path : Fs.Path}))
    | SyncResult (List (ToElm v))


{-| Created as well as moved and renamed files appear as "Modify"
-}
type Edit
    = Remove
    | Modify


type FromElm
    = Read Fs.Path
    | RemoteRead Url
    | Write Fs.Path String
    | Delete Fs.Path
    | Watch (List Fs.Path)
    | ReadDirs (List Fs.Path)
    | Print String
    | Exit String
    | Sync (List FromElm)


type alias Flags =
    { fsContext : Fs.Context
    }


toElmCodec : TsC.Codec (ToElm v)
toElmCodec =
    TsC.recursive
        (\self ->
            TsC.custom (Just "tag")
                (\watchVariant readResultVariant remoteReadResult writeResultVariant readDirsResult syncResult value ->
                    case value of
                        WatchEvent path edit ->
                            watchVariant path edit

                        ReadResult address result ->
                            readResultVariant address result

                        RemoteReadResult url result ->
                            remoteReadResult url result

                        WriteResult path result ->
                            writeResultVariant path result

                        ReadDirsResult result ->
                            readDirsResult result

                        SyncResult resultList ->
                            syncResult resultList
                )
                |> TsC.namedVariant2 "WatchEvent" WatchEvent ( "path", pathCodec ) ( "edit", editCodec )
                |> TsC.namedVariant2 "ReadResult" ReadResult ( "path", pathCodec ) ( "content", TsC.result TsC.string TsC.string )
                |> TsC.namedVariant2 "RemoteReadResult" RemoteReadResult ( "url", urlCodec ) ( "content", TsC.result TsC.string TsC.string )
                |> TsC.namedVariant2 "WriteResult" WriteResult ( "path", pathCodec ) ( "result", TsC.result TsC.string TsC.string )
                |> TsC.namedVariant1 "ReadDirsResult" ReadDirsResult ( "result", TsC.result TsC.string fsCodec )
                |> TsC.namedVariant1 "SyncResult" SyncResult ( "results", TsC.list self )
                |> TsC.buildCustom
        )


editCodec : TsC.Codec Edit
editCodec =
    TsC.stringUnion
        [ ( "Remove", Remove )
        , ( "Modify", Modify )
        ]


fromElmCodec : TsC.Codec FromElm
fromElmCodec =
    TsC.recursive
        (\fromElmCodec_ ->
            TsC.custom (Just "tag")
                (\readVariant remoteRead writeVariant removeVariant watchVariant readDirVariant printVariant exitVariant syncVariant value ->
                    case value of
                        Read path ->
                            readVariant path

                        RemoteRead url ->
                            remoteRead url

                        Write path content ->
                            writeVariant path content

                        Delete path ->
                            removeVariant path

                        Watch pathList ->
                            watchVariant pathList

                        ReadDirs paths ->
                            readDirVariant paths

                        Print message ->
                            printVariant message

                        Exit message ->
                            exitVariant message

                        Sync fromElmList ->
                            syncVariant fromElmList
                )
                |> TsC.namedVariant1 "Read" Read ( "path", pathCodec )
                |> TsC.namedVariant1 "RemoteRead" RemoteRead ( "url", urlCodec )
                |> TsC.namedVariant2 "Write" Write ( "path", pathCodec ) ( "content", TsC.string )
                |> TsC.namedVariant1 "Delete" Delete ( "path", pathCodec )
                |> TsC.namedVariant1 "Watch" Watch ( "paths", TsC.list pathCodec )
                |> TsC.namedVariant1 "ReadDirs" ReadDirs ( "paths", TsC.list pathCodec )
                |> TsC.namedVariant1 "Print" Print ( "message", TsC.string )
                |> TsC.namedVariant1 "Exit" Exit ( "message", TsC.string )
                |> TsC.namedVariant1 "Sync" Sync ( "fromElmList", TsC.list fromElmCodec_ )
                |> TsC.buildCustom
        )


flagsCodec : TsC.Codec Flags
flagsCodec =
    TsC.object (\fsContext -> { fsContext = fsContext })
        |> TsC.field "fsContext" .fsContext contextCodec
        |> TsC.buildObject


contextCodec : TsC.Codec Fs.Context
contextCodec =
    TsC.object (\current {-home-} -> { current = current{-, home = home-} })
        |> TsC.field "current" .current pathCodec
        -- |> TsC.field "home" .home pathCodec
        |> TsC.buildObject


pathCodec : TsC.Codec Fs.Path
pathCodec =
    codecFromToString
        { toString = Fs.Path.toString
        , fromString = Fs.Path.fromString >> Result.fromMaybe "Bad Url"
        }


urlCodec : TsC.Codec Url
urlCodec =
    codecFromToString
        { toString = Url.toString
        , fromString = Url.fromString >> Result.fromMaybe "Bad Url"
        }


codecFromToString : { toString : a -> String, fromString : String -> Result String a } -> TsC.Codec a
codecFromToString { toString, fromString } =
    TsC.build
        (TsE.map toString TsE.string)
        (TsD.andThen
            (TsD.andThenInit
                (fromString
                    >> Result.map TsD.succeed
                    >> Result.Extra.extract TsD.fail
                )
            )
            TsD.string
        )


fsCodec : TsC.Codec (List { path : Fs.Path, isFile : Bool })
fsCodec =
    let
        isFileCodec : TsC.Codec Bool
        isFileCodec =
            TsC.stringUnion
                [ ( "File", True )
                , ( "Directory", False )
                ]
    in
    TsC.object (\path isFile -> { path = path, isFile = isFile })
        |> TsC.field "path" .path pathCodec
        |> TsC.field "entry" .isFile isFileCodec
        |> TsC.buildObject
        |> TsC.list



--// ██████╗  ██████╗ ██████╗ ████████╗███████╗
--// ██╔══██╗██╔═══██╗██╔══██╗╚══██╔══╝██╔════╝
--// ██████╔╝██║   ██║██████╔╝   ██║   ███████╗
--// ██╔═══╝ ██║   ██║██╔══██╗   ██║   ╚════██║
--// ██║     ╚██████╔╝██║  ██║   ██║   ███████║
--// ╚═╝      ╚═════╝ ╚═╝  ╚═╝   ╚═╝   ╚══════╝


{-| -}
send : FromElm -> Cmd msg
send fromElm =
    fromElm
        |> (interop.fromElm |> TsE.encoder)
        |> interopFromElm


{-| -}
subscribe : Sub (Result D.Error (ToElm v))
subscribe =
    (interop.toElm |> TsD.decoder)
        |> D.decodeValue
        |> interopToElm


{-| -}
decodeFlags : D.Value -> Result D.Error Flags
decodeFlags flags =
    D.decodeValue
        (interop.flags |> TsD.decoder)
        flags



-- internals - do not expose


port interopFromElm : E.Value -> Cmd msg


port interopToElm : (D.Value -> msg) -> Sub msg
