module Fs exposing (..)

import Dict exposing (Dict)
import NeList exposing (NeList)
import RemoteData exposing (RemoteData)


type Path
    = Path (NeList String)


type Entry v
    = File (RemoteData String v)
    | Directory (Tree v)


type alias Tree v =
    Dict String (Entry v)
