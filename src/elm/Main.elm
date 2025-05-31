module Main exposing (..)

import Json.Decode as D
import Platform
import Result.Extra
import Ts
import Fs
import Fs.Tree
import Fs.Path
import Fs.Tree
import Tuple.Extra


type alias Model =
    { fs : Fs.Tree String
    , watch : List Fs.Path
    }

type Msg
    = FromTs (Ts.ToElm String)
    | TsDecodeError D.Error


main : Platform.Program D.Value Model Msg
main =
    Platform.worker
        { init =
            \val ->
                case Ts.decodeFlags val of
                    Err error ->
                        "Flags incorrectly parsed : " ++ D.errorToString error |> exit

                    Ok flags ->
                        init flags
        , update = update
        , subscriptions =
            \_ ->
                Ts.subscribe |> Sub.map (Result.map FromTs >> Result.Extra.extract TsDecodeError)
        }


init : Ts.Flags -> ( Model, Cmd Msg )
init { fsContext } =
    ( { fs = Fs.Tree.empty fsContext, watch = [] }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        TsDecodeError err ->
            D.errorToString err |> exit

        FromTs (Ts.ReadDirsResult (Ok changes)) ->
            { model
            | fs =
                Fs.Tree.union
                    { keepSecondFileDataWhenFistIsNotAsked = True }
                    (Fs.Tree.fromList (Tuple.first model.fs) changes)
                    model.fs
            }
            |> Tuple.Extra.pairWith Cmd.none

        FromTs (Ts.ReadDirsResult (Err err)) ->
            exit err

        FromTs (Ts.WatchEvent path Ts.Remove) ->
            { model | fs = Fs.Tree.remove path model.fs }
            |> Tuple.Extra.pairWith Cmd.none

        -- FromTs (Ts.WatchEvent path Ts.Modify) ->
        --     case Fs.Tree.get path model.fs of
        --         Just ()
        --     { model | fs = Fs.Tree.remove path model.fs }
        --     |> Tuple.Extra.pairWith Cmd.none

        _ -> (model, Cmd.none)
        -- FromTs ReadResult Fs.Path (Result String String) ->
        -- FromTs RemoteReadResult Url (Result String String) ->
        -- FromTs WriteResult Fs.Path (Result String String) ->
        -- FromTs SyncResult (List (FromTs v)) ->



-- UTIL --


exit : String -> ( Model, Cmd Msg )
exit msg =
    let dummyContext = { home = Fs.Path.root, current = Fs.Path.root } in
    ( { fs = Fs.Tree.empty dummyContext, watch = [] }
    , Ts.send (Ts.Exit msg)
    )
