module Fs.FileData exposing (..)

import Fs exposing (..)

getPreviousSuccess : FileData v -> Maybe v
getPreviousSuccess fileData =
    case fileData of
        Success data ->
            Just data

        Loading {previousSuccess} ->
            previousSuccess

        Failure {previousSuccess} ->
            previousSuccess

        _ ->
            Nothing
