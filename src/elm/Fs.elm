module Fs exposing (..)

import Dict exposing (Dict)
import NeList exposing (NeList)


type Path
    = Path (NeList String)

type Entry v
    = File (FileData v)
    | Directory (InternalTree v)


type FileData v
    = NotAsked
    | Loading { previousSuccess : Maybe v }
    | Success v
    | Failure { previousSuccess : Maybe v, errorMsg : String }

type alias Tree v =
    (Context, InternalTree v)

type alias InternalTree v =
    Dict String (Entry v)

type alias Context =
    { current : Path
    , home : Path
    }
