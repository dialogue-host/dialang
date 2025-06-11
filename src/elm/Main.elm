module Main exposing (..)

import Json.Decode as D
import Platform
import Result.Extra
import Ts
import Ts.FromElm
import Ts.ToElm
import Fs
import Fs.Tree
import Fs.Path
import Fs.Tree
import Tuple.Extra
import Console


type alias Model =
    { fs : Fs.Tree String
    }

type Msg
    = FromTs (Ts.ToElm String)
    | TsDecodeError D.Error

type alias Effects = List Ts.FromElm

watchedDir : Fs.Path
watchedDir =
    Fs.Path.fromString "./src/dia"
    |> Maybe.withDefault Fs.Path.home


main : Platform.Program D.Value Model Msg
main =
    Platform.worker
        { init = \val ->
            ( case Ts.decodeFlags val of
                Err error ->
                    "Flags incorrectly parsed : " ++ D.errorToString error
                    |> exit

                Ok flags ->
                    init flags
            )
            |> Tuple.mapSecond effectsToCmd

        , update = \msg model ->
            update msg model
            |> Tuple.mapSecond effectsToCmd
            |> printFromTs msg

        , subscriptions = \_ ->
            Ts.subscribe |> Sub.map (Result.map FromTs >> Result.Extra.extract TsDecodeError)
        }


init : Ts.Flags -> ( Model, Effects )
init { fsContext } =
    let
        helloMsg =
            Console.red "\n==== DIALANG ===="
            ++ "\n\nRunning with `"
            ++ Fs.Path.toString fsContext.current ++ "` as root directory."

        effects =
            [ Ts.Print helloMsg
            , Ts.ReadDirs [ Fs.Path.toAbsolute fsContext watchedDir ]
            ]
    in
    ( { fs = Fs.Tree.empty fsContext }
    , effects
    )


update : Msg -> Model -> ( Model, Effects )
update msg model =
    case msg of
        TsDecodeError err ->
            D.errorToString err |> exit

        FromTs (Ts.ReadDirsResult (Ok changes)) ->
            ( { model
              | fs =
                List.foldl
                    (\{path, isFile} ->
                        if isFile
                        then Fs.Tree.setFileToLoading path
                        else Fs.Tree.insertDir path
                    )
                    model.fs
                    changes
              }
            , List.map (.path >> Ts.Read) changes
            )

        FromTs (Ts.ReadDirsResult (Err err)) ->
            exit err

        FromTs (Ts.WatchEvent path Ts.Remove) ->
            { model | fs = Fs.Tree.remove path model.fs }
            |> Tuple.Extra.pairWith []

        FromTs (Ts.WatchEvent path Ts.Modify) ->
            if True
            then
                { model | fs = Fs.Tree.setFileToLoading path model.fs }
                |> Tuple.Extra.pairWith [ Ts.Read path ]
            else
                { model | fs = Fs.Tree.insert path (Fs.File Fs.NotAsked) model.fs }
                |> Tuple.Extra.pairWith []

        FromTs (Ts.ReadResult path (Ok content)) ->
            { model | fs = Fs.Tree.insert path (Fs.File <| Fs.Success content) model.fs }
            |> Tuple.Extra.pairWith []

        FromTs (Ts.ReadResult path (Err readErr)) ->
            exit <| "Unable to read " ++ Fs.Path.toString path ++ " : "++ readErr

        FromTs (Ts.RemoteReadResult _ _) ->
            exit "Remote reads not handled."

        FromTs (Ts.WriteResult path (Ok content)) ->
            { model | fs = Fs.Tree.insert path (Fs.File <| Fs.Success content) model.fs }
            |> Tuple.Extra.pairWith []

        FromTs (Ts.WriteResult path (Err writeErr)) ->
            "Unable to write " ++ Fs.Path.toString path ++ " : "++ writeErr |> exit

        FromTs (Ts.SyncResult toElmList) ->
            List.foldl
                (\toElm (model_, effects) ->
                    update (FromTs toElm) model_
                    |> Tuple.mapSecond (\e -> e ++ effects)
                )
                (model, [])
                toElmList


-- UTIL --


exit : String -> ( Model, Effects )
exit msg =
    let dummyContext = { {-home = Fs.Path.root,-} current = Fs.Path.root } in
    ( { fs = Fs.Tree.empty dummyContext }
    , [ Ts.Exit msg ]
    )


effectsToCmd : Effects -> Cmd Msg
effectsToCmd effects =
    List.foldl
        (\effect cmdList ->
            ( [ Console.red "<< " ++ Ts.FromElm.toString effect
                |> Ts.Print
              , effect
              ]
              |> List.map Ts.send
            )
            ++ cmdList
        )
        []
        effects
    |> Cmd.batch


printFromTs : Msg -> (m, Cmd Msg) -> (m, Cmd Msg)
printFromTs msg (model, cmd) =
    case msg of
        FromTs toElm ->
            let
                printMsg =
                    Console.red ">> " ++ Ts.ToElm.toString toElm
                    |> Ts.Print
                    |> Ts.send
            in
            Cmd.batch [printMsg, cmd]
            |> Tuple.pair model

        _ ->
            (model, cmd)
