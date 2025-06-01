module Fs.Context exposing (..)

import Fs exposing (..)
import Fs.Path as Path

isValid : Context -> Bool
isValid {current {-, home -}} =
    case (current{-, home-}) of
        (Path ("", _){-, Path ("", _)-}) ->
            Path.reduce current == current
            {-&& Path.reduce home == home-}

        _ ->
            False
