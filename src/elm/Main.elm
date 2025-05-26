module Main exposing (..)

import Json.Decode as D
import Platform
import Result.Extra
import Ts


type alias Model =
    {}


type Msg
    = FromTs (Ts.ToElm ())
    | DecodeError D.Error


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
                Ts.subscribe |> Sub.map (Result.map FromTs >> Result.Extra.extract DecodeError)
        }


init : Ts.Flags -> ( Model, Cmd Msg )
init _ =
    ( {}, Ts.Print "Hello World!" |> Ts.send )


update : Msg -> Model -> ( Model, Cmd Msg )
update _ _ =
    ( {}, Cmd.none )



-- UTIL --


exit : String -> ( Model, Cmd Msg )
exit msg =
    ( {}, Ts.send (Ts.Exit msg) )
